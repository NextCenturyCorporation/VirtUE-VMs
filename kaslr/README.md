# Information about patches and licenses

Authors: Hassan Nadeem, Ruslan Nikolaev (Virginia Tech)

1. The PIE patch was originally found on the kernel-hardening mailing
list (it is partially used by our PIC patch; however, we do *not* enable PIE):

pie-patch-mailing-list.patch

The patch series is coming from
https://www.openwall.com/lists/kernel-hardening/2018/06/26/1

2. Our PIC patch (support for position-independent modules) patch should be
applied on top of it:

pic-modules-support.patch

Since we modify the existing Linux kernel, the original Linux kernel license
applies to this patch.

3. For ENA module re-randomization support, apply kaslr.patch on top of it:

The original Linux kernel license applies to this patch, except our SMR code.
Our patch also includes SMR (Safe Memory Reclamation) which comes from our
different project and is licensed under BSD-2-Clause.

# Instructions

1. Install Prerequisites

$ sudo yum install asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc java-devel m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl patch pciutils-devel perl perl-ExtUtils-Embed python-devel python-docutils redhat-rpm-config rpm-build tar xmlto xz zlib-devel openssl-devel rpmdevtools

$ rpmdev-setuptree

2. Download linux kernel v4.18.20

$ wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.18.20.tar.xz

3. Untar and change directory

$ tar -xf linux-4.18.20.tar.xz

$ cd linux-4.18.20/

4. Apply patches in order (from Virtue-VMs/kaslr)

patch -p1 < pie-patch-mailing-list.patch
patch -p1 < pic-modules-support.patch
patch -p1 < kaslr.patch

5. Copy Configuration File (from Virtue-VMs/kaslr)

cp config-aws .config


6. Build rpm packages

To compile source, headers and binaries

$  make rpm-pkg -j8

The rpm packages would be saved in ~/rpmbuild/RPMS/x86_64

7. Install the new kernel

Delete previous installations of kernel if any

$ sudo rpm -e kernel-4.18.20+*

Install new kernel

$ cd ~/rpmbuild/RPMS/x86_64

$ sudo rpm -iv kernel-4.18.20*.rpm kernel-devel-4.18.20*.rpm

Ignore modinfo: ERROR: Module nf_nat_masquerade_ipv4 not found.
This modules is built into the kernel. It can not be compiled as a module in 4.18.20

8. Configure to boot into new kernel

sudo cp -i menu.lst /boot/grub/menu.lst

# Start randomization (should be in our init scripts)

$ modprobe randmod module_name=ena rand_period=100 manual_unmap=0


End randomization

$ rmmod randmod


# Start randomization on startup

Add modprobe command to /etc/rc.local to start randomization at startup.
