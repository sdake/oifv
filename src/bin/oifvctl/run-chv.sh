# this bash script needs to be integrated into oifvctl.

# The MAC address must be attached to the macvtap and be used inside the guest
mac="c2:67:4f:53:29:cb"
# Host network adapter to bridge the guest onto
host_net="eno1"

oifv_fs_sock="${HOME}"/oifv_fs.sock
oifv_pid="${HOME}"/oifv_fs.pid
oifv_api_sock="${HOME}"/oifv.sock
oifv_vsock="${HOME}"/oifv.vsock
oifv_log="${HOME}"/oifv.log
rm -f "${oifv_fs_sock}"
rm -f "${oifv_pid}"
rm -f "${oifv_api_sock}"
rm -f "${oifv_vsock}"
rm -f "${oifv_log}"

disk_img="${HOME}"/debian_disk.raw
kernel_img="${HOME}"/hypervisor-fw

sudo rm -f /tmp/ch.vsock

###
# This device may not be hairpinned, so you will need to login to this node from a host not running the hypervisor
echo "Creating bridged network device to eno1"
sudo driverctl set-override 0000:d8:00.0 vfio-pci
sudo ip link delete link "${host_net}" name macvtap0

###
# Create a macvvtap on the host network
sudo ip link add link "${host_net}" name macvtap0 type macvtap
sudo ip link set macvtap0 address "${mac}" up
sudo ip link show macvtap0

# A new character device is created for this interface
tapindex=$(< /sys/class/net/macvtap0/ifindex)
tapdevice="/dev/tap$tapindex"

# Ensure that we can access this device
sudo chown "$UID.$UID" "$tapdevice"

echo "sharing local $HOME/repos"
virtiofsd \
    --socket-path="${oifv_fs_sock}" \
    --shared-dir=${HOME}/repos \
    --cache=never \
    --thread-pool-size=4 &

sleep 2

echo "Running hypervisor"
cloud-hypervisor \
	--api-socket "${oifv_api_sock}" \
	--kernel "${kernel_img}" \
	--disk path="${disk_img}" \
	--serial tty \
	--console pty \
        --cmdline "module_blacklist=nouveau,nvidiafb root=/dev/vda1 rw" \
	--cpus "boot=64" \
	--memory "size=64G,hugepages=on,shared=on,hugepage_size=2M" \
        --net fd=3,mac=${mac} 3<>$"${tapdevice}" \
	-v \
	--fs tag=homefs,socket="${oifv_fs_sock}",num_queues=1,queue_size=512 \
	--vsock cid=3,socket="${oifv_vsock}" \
	--log-file "${oifv_log}" \
	--device path="/sys/bus/pci/devices/0000:5e:00.0" \
       		path="/sys/bus/pci/devices/0000:d8:00.0"

sudo ip link delete link "$host_net" name macvtap0
sudo kill -15 viritofsd
