# this bash script needs to be integrated into oifvctl.

sudo rm -f /tmp/ch.vsock

echo "Creating bridged network device to eno1"
sudo driverctl set-override 0000:d8:00.0 vfio-pci
sudo ip link delete link "$host_net" name macvtap0

# The MAC address must be attached to the macvtap and be used inside the guest
mac="c2:67:4f:53:29:cb"
# Host network adapter to bridge the guest onto
host_net="eno1"

sudo ip link delete link "$host_net" name macvtap0
# Create the macvtap0 as a new virtual MAC associated with the host network
sudo ip link add link "$host_net" name macvtap0 type macvtap
sudo ip link set macvtap0 address "$mac" up
sudo ip link show macvtap0

# A new character device is created for this interface
tapindex=$(< /sys/class/net/macvtap0/ifindex)
tapdevice="/dev/tap$tapindex"

# Ensure that we can access this device
sudo chown "$UID.$UID" "$tapdevice"

echo "sharing $HOME/repos"
rm -f /tmp/virtiofs*
virtiofsd \
    --socket-path=/tmp/virtiofs \
    --shared-dir=$HOME/repos \
    --cache=never \
    --thread-pool-size=4 &

sleep 2

echo "Running hypervisor"
cloud-hypervisor \
	--kernel ./hypervisor-fw \
	--serial tty \
	--console pty \
	--disk path=/home/sdake/debian_disk.raw \
        --cmdline "module_blacklist=nouveau,nvidiafb root=/dev/vda1 rw" \
	--cpus "boot=64" \
	--memory "size=64G,hugepages=on,shared=on,hugepage_size=2M" \
        --net fd=3,mac=$mac 3<>$"$tapdevice" \
	-v \
	--fs tag=homefs,socket=/tmp/virtiofs,num_queues=1,queue_size=512 \
	--vsock cid=3,socket=/tmp/ch.vsock \
	--log-file "/home/sdake/chv.log" \
	--device path="/sys/bus/pci/devices/0000:5e:00.0" \
       		path="/sys/bus/pci/devices/0000:d8:00.0"

sudo ip link delete link "$host_net" name macvtap0
sudo kill -15 viritofsd
