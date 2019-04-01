#!/bin/sh 
sudo patch -d /etc -p1 < ../xen/sudoers.patch
sudo cp ../xen/local.conf /etc/ld.so.conf.d
sudo ldconfig
