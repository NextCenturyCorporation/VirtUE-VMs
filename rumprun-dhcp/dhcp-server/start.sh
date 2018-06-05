#!/bin/sh

export PATH="${PATH}:/usr/local/bin:/usr/local/sbin:$(pwd)/../rumprun/bin"

rumprun -S xen -i -b disk.img,/ -I dhcp0,xenif,bridge=xenbr0,vifname=vif-dhcp -W dhcp0,inet,static,192.168.0.3/24,192.168.0.1 dhcpd.bin -v -i opendhcp.ini
