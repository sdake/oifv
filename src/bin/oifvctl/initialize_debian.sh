# Download Debian Bullseye (11) raw image
# curl -LO https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.raw

# make a duplicate
cp -a debian-11-generic-amd64.raw debian_disk.raw

qemu-img resize debian_disk.raw +20G

# customize raw image password
virt-customize -a debian_disk.raw --root-password password:password
