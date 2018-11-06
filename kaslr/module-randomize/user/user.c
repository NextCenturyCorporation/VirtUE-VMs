#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#include "../ioctl.h"

void trim(char *string){
    const char* firstNonSpace = string;

    while(*firstNonSpace != '\0' && isspace(*firstNonSpace)){
        ++firstNonSpace;
    }

    size_t len = strlen(firstNonSpace)+1;         

    memmove(string, firstNonSpace, len);

    /* Now remove trailing spaces */
    int i = strlen(string) - 1;
    while (isspace(string[i]))
        string[i--] = '\0';
}

int main(int argc, char **argv)
{
    int fd, arg_int = 0, ret;
    char input[100];

    // Open ioctrl file
    fd = open("/sys/kernel/debug/randomize/mod", O_RDONLY);
    if (fd == -1) {
        perror("open");
        return EXIT_FAILURE;
    }

    do{
        fgets(input,sizeof(input),stdin);
        trim(input);
        ret = ioctl(fd, RANDMOD_RANDOMIZE, &arg_int);
        // if(input[0] == '1'){
        //     ret = ioctl(fd, LKMC_IOCTL_DEC, &arg_int);
            
        // }else{
        //     ret = ioctl(fd, LKMC_IOCTL_INC, &arg_int);
        // }

        if (ret == -1) {
            perror("ioctl");
            return EXIT_FAILURE;
        }

        printf("arg = %d\n", arg_int);
    }while(strcmp(input, "exit") != 0);

    close(fd);
    return EXIT_SUCCESS;
}