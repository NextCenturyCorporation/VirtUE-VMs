#!/bin/sh

export PATH="${PATH}:/usr/local/bin:/usr/local/sbin:$(pwd)/../rumprun/bin"

rumprun xen -i -b nfsd.img,/disk -I nfsd0,xenif,bridge=xenbr0,vifname=vif-nfs -W nfsd0,inet,static,192.168.0.2/24 nfsd.bin
