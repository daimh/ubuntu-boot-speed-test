#!/usr/bin/env sh
set -xeEu
cat << EOF > /etc/modprobe.d/test-blacklist.conf
blacklist floppy 
blacklist raid456 
blacklist btrfs
blacklist raid6_pq
blacklist raid0
blacklist raid1 
blacklist raid10 
blacklist multipath
blacklist dm_multipath
EOF
update-initramfs -u
