A rumprun-based unikernel

Authors: Ruslan Nikolaev, Mincheol Sung (Virginia Tech)

# Installation

1. Prepare rumprun (as described in the rumprun instructions)

2. Patch rumprun-bake.conf to support NFS:

cd rumprun

patch -p1 < rumprun-bake-nfsd.patch

patch -p1 < rumprun-persistent\_storage.patch

Also copy nfsd subdirectory to rumprun

3. Compile rumprun (as described in the rumprun instructions)

4. Go to nfsd subdirectory

5. Run ./generate.sh to create 512 Mb file system

6. Run ./compile.sh to create nfsd.bin

7. Run ./start.sh when you are ready to launch the NFS unikernel


To mount in Linux VM:

sudo mount -t nfs 192.168.0.2:/disk/nfs <directory_to_mount_to>


To see all exports in Linux VM:

sudo showmount -e 192.168.0.2
