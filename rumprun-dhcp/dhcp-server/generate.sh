#!/bin/sh

rm -f disk.img
dd if=/dev/zero of=disk.img bs=1M count=50
mkfs.ext3 -b 4096 disk.img
mkdir ./_fs
sudo mount -t ext3 -o loop disk.img ./_fs
sudo cp opendhcp.ini ./_fs/
sudo umount ./_fs
rmdir ./_fs
sync