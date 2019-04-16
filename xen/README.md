# Xen configuration

Authors: Mincheol Sung, Ruslan Nikolaev (Virginia Tech)

## Instructions

1. Comment out handle\_iptable in /etc/xen/scripts/vif-bridge

2. Then:

cd /etc

sudo patch -p1 < $CURDIR/sudoers.patch

sudo cp $CURDIR/local.conf /etc/ld.so.conf.d/

sudo ldconfig

3. Copy start-up scripts from config
