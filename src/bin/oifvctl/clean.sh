sudo killall -15 virtiofsd
sudo killall -15 vhost_user_net
sudo killall -15 cloud-hypservisor

host_net="eno1"

sudo ip link delete link "$host_net" name macvtap0
oifv_fs_sock="${HOME}"/oifv_fs.sock
oifv_pid="${HOME}"/oifv_fs.pid
oifv_api_sock="${HOME}"/oifv.sock
oifv_vsock="${HOME}"/oifv.vsock
oifv_log="${HOME}"/oifv.log
oifv_net_sock="${HOME}"/oifv_net_sock.log
rm -f "${oifv_fs_sock}"
rm -f "${oifv_pid}"
rm -f "${oifv_api_sock}"
rm -f "${oifv_vsock}"
rm -f "${oifv_log}"
rm -f "${oifv_net_sock}"
