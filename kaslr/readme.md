## Steps
0. Install patched linux kernel v4.16
1. Compile driver as PIC by adding `EXTRA_CFLAGS` to Makefile of the driver.
2. Create a PIC shared object using `makeso.sh`.
3. Load the PIC module using `sudo insmod`.

## Linux Kernel Patch
- Clone linux v4.16 `git clone --branch v4.16 --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- Apply all patches `git apply *.patch`
- Copy config file for kernel configation in the linux directory `cp aws-config .config`
- Build linux kernel `make all -j8`
- Install kernel `sudo make headers_install modules_install install`
- Restart to boot into new kernel

## Compiling a driver as PIC
- Add the following file at the end of the Makefile of the driver to be compiled as PIC

`EXTRA_CFLAGS = -fPIC -mcmodel=small -fno-stack-protector -fvisibility=hidden -DPIC_MODULE`

Amazon Ethernet driver Makefile is located in `drivers/net/ethernet/amazon/ena/Makefile`

Intel Ethernet driver Makefile is located in`drivers/net/ethernet/intel/e1000/Makefile`

- Build the driver with `make SUBDIRS=drivers/net/ethernet/amazon/ena modules -j16` this would create `ena.ko` file
- Create a `.kso` object file with `./makeso.sh ena.ko` this would produce an `ena.kso` file
- Load the PIC module with `sudo insmod ena.kso`
