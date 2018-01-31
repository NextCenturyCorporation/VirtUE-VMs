#!/bin/sh

export PATH="${PATH}:$(pwd)/../rumprun/bin"

rumprun xen -i -b nfsd.img,/disk -n inet,static,10.0.0.2/24 nfsd.bin
