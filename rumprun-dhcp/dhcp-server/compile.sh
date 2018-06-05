#!/bin/sh

export PATH="${PATH}:$(pwd)/../rumprun/bin"

rm -f dhcpd dhcpd.bin
x86_64-rumprun-netbsd-g++ -pthread -o dhcpd  opendhcpd.cpp -DRUMPRUN

rumprun-bake xen_pv dhcpd.bin dhcpd

# delete unbaked binary to avoid confusion
rm -f dhcpd
