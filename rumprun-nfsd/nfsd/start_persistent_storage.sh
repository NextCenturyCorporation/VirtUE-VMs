#!/bin/sh

export PATH="${PATH}:/usr/local/bin:/usr/local/sbin:$(pwd)/../rumprun/bin"

rumprun xen -i -b /dev/nvme1n1,/disk -I nfsd0,xenif,bridge=xenbr0,vifname=vif-nfs -W nfsd0,inet,static,192.168.0.2/24,192.168.0.1 nfsd.bin
