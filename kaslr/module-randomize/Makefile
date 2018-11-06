KDIR := /home/hnadeem/repos/linux
ROOTDIR := /home/hnadeem/repos/linux

obj-m += randmod.o
# hello-objs := hello_main.o hello_func.o


all: randmod.c
	@make -C $(KDIR) M=$(PWD) modules > /dev/null

insert:
	sudo insmod randmod.ko

remove:
	sudo rmmod randmod

run: all
	(sudo dmesg --clear && make insert && sleep 1 && make remove) > /dev/null ; dmesg

replace:
	sudo rmmod e1000 ; sudo modprobe e1000

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
	# rm -f 

install:
	sudo cp randmod.ko /lib/modules/`uname -r`/kernel/drivers