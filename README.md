# VirtUE-VMs

Authors: Ruslan Nikolaev, Mincheol Sung, Hassan Nadeem (Virginia Tech)

## Compiling rumprun unikernels

1. Get rumprun source code

git clone https://github.com/rumpkernel/rumprun

git submodule update --init

(This fetches additional source code from external repos)

2. Apply all necessary patches from rumprun-nfsd

[ Also replace build-rr.sh script with the one from this directory. ]

If you hit a compiler error
src-netbsd/sys/lib/libunwind/AddressSpace.hpp:143
just replace (-1LL) with (uint64\_t) (-1LL)

3. You may also need to copy Xen headers if they were installed to
/usr/local/include as follows:

sudo cp -r /usr/local/include/xen/* /usr/include/xen/

4. Compile rumprun (for Xen)

CC=cc ./build-rr.sh xen

5. You need to set up network bridging in Xen. By default,
the NFS unikernel (currently) assumes IP address: 192.168.0.2 and
netmask: 255.255.255.0.

An example script for that is 'bridge.sh' which would normally
be executed after Dom0 boot-up. Make sure to change the
physical interface in the last line: --out-interface wlp3s0
(e.g., specify your actual NIC interface such as eth0, wlp3s0, etc)

6. For automatic start-up on Amazon Linux, see rc.local file.
It needs to be placed to /etc/rc.d/rc.local
