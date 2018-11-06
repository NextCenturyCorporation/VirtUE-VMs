#ifndef IOCTL_H
#define IOCTL_H

#include <linux/ioctl.h>

// typedef struct {
//     int i;
//     int j;
// } lkmc_ioctl_struct;
#define RANDMOD_MAGIC 0x33
#define RANDMOD_RANDOMIZE     _IOWR(RANDMOD_MAGIC, 0, int)
#define RANDMOD_MAP           _IOWR(RANDMOD_MAGIC, 1, int)
#define RANDMOD_UNMAP         _IOWR(RANDMOD_MAGIC, 2, int)

#endif