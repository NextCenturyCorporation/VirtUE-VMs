#include <linux/module.h>	/* Needed by all modules */
#include <linux/kernel.h>	/* Needed for KERN_INFO */
#include <linux/moduleparam.h>
#include <linux/delay.h>
#include <linux/list.h>
#include <linux/debugfs.h>
#include <linux/uaccess.h>

#include "ioctl.h"

// Macros
#define printi(x) printk("%d." #x " = %d\n", __LINE__, x)

// Global Variables
static struct dentry *dir;
void *module_relocate(struct module *mod);

int memoryMatch(int *p1, int *p2, int len){
	int i = 0;
	len /= sizeof(int);
	for(i=0; i<len; i++){
		if(*p1 != *p2){
			printk("ERROR: Addresses do not match\n");
			return false;
		}
		// printk( "0x%lx = %0xlx\n", p1, *p1 );
		// printk( "0x%lx = %0xlx\n", p2, *p2 );
		// printk("\n");
		p1++;p2++;
	}

	return true;
}

int randomize(const char *name){
	void *oldAddr, *newAddr;
	struct module *mod;

	printk(KERN_INFO "------ Start Randomization ------\n");

	mod = find_module(name);

	if(mod == NULL){
		printk("ERR: Module not found");
		return -1;
	}

	printk("Randomizing %s\n", mod->name);

	if( !mod->isSharedObject || mod->init_layout.size > 0){
		printk("module is not a shared object or has an init section");
		printk("ERR: Module can not be relocated");
		return -1;
	}

	oldAddr = mod->core_layout.base;

	newAddr = module_relocate(mod);
	printk("Old Address = 0x%lx", (unsigned long)oldAddr);
	printk("New Address = 0x%lx", (unsigned long)newAddr);
	printk("Size = 0x%lx", (unsigned long) mod->core_layout.size);


	// memoryMatch((int *) oldAddr, (int *) newAddr, mod->core_layout.size);

	mdelay(500);
	unmap_module(oldAddr);
	// mdelay(500);

	printk(KERN_INFO "------ End Randomization ------\n");

	return 0;
}


static long unlocked_ioctl(struct file *filp, unsigned int cmd, unsigned long argp){
	void __user *arg_user;

	arg_user = (void __user *)argp;
	
	int res = randomize("ioctrl");
	if (copy_to_user(arg_user, &res, sizeof(res)))  return -EFAULT;

	// switch(cmd){
	// 	case RANDMOD_RANDOMIZE:
	// 		break;
	// 	case RANDMOD_MAP:
	// 		break;
	// 	case RANDMOD_UNMAP:
	// 		break;
	// 	default:
	// 		return -EINVAL;
	// }
	return 0;
}

struct file_operations fops = {
    .owner = THIS_MODULE,
    .unlocked_ioctl = unlocked_ioctl
};

int init_module(void){
	dir = debugfs_create_dir("randomize", 0);
	debugfs_create_file("mod", 0, dir, NULL, &fops);

    return 0;
}

void cleanup_module(void){
	debugfs_remove_recursive(dir);
}

MODULE_LICENSE("GPL v2");