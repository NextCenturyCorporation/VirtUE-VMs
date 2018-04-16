#!/bin/sh 
sudo patch -d /etc -p1 < ./sudoers.patch
sudo cp ./local.conf /etc/ld.so.conf.d
sudo ldconfig
