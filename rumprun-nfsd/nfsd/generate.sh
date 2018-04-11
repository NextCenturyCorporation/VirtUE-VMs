#!/bin/sh

dd if=/dev/zero of=nfsd.img bs=1M count=512
mkfs.ext3 -b 4096 nfsd.img
mkdir ./_fs
sudo mount -t ext3 -o loop nfsd.img ./_fs
sudo mkdir -p ./_fs/var/db ./_fs/nfs
sudo chmod 777 ./_fs/nfs
sudo umount ./_fs
rmdir ./_fs
sync
