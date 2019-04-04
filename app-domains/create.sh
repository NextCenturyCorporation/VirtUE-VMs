#!/bin/bash

# simple key-value store for Domain names
source kv-bash/kv-bash

# Number of configuration generated
COUNT=`kvget count`
if [ -z "$COUNT" ]; then COUNT=1; fi

# Role to virtual interface name mapping
declare -A roles
roles=( ["default"]="vif-def" ["email"]="vif-email" ["power"]="vif-pow" ["god"]="vif-god")

# This is the default role when no role is specified
DOM_ROLE="default"

if [ "$#" = "1" ]
then
	echo "Domain name will be randomly selected"
	RANDOM_NUMBER=0
	while true
	do
		RANDOM_NUMBER=$((RANDOM_NUMBER + 1))
		DOM_NAME="app-domain-$RANDOM_NUMBER"
		DUPLICATE=`kvget $DOM_NAME`
		if [ "$DUPLICATE" = "1" ]
		then
			continue
		else
			echo "Domain name is selected as $DOM_NAME"
			break
		fi
	done
elif [ "$#" = "0" ]
then
	echo "Usage create.sh <template> <domain name> <role>"
	exit

elif [ "$#" -gt "3" ]
then
	echo "Usage create.sh <template> <domain name> <role>"
	exit
fi

TEMPLATE_PATH="$1"

if [ "$#" -gt "2" ]
then
	if [ "$2" = "master" ]
	then
		echo "Dom name should not be master"
		exit
	fi
	DOM_NAME="$2"
fi

if [ "$#" = "2" ]
then
    DOM_ROLE="$3"
fi

if [ -z ${roles["$DOM_ROLE"]} ]
then
    echo "Invalid role entered"
    exit
fi

DOM_VIF=${roles["$DOM_ROLE"]}-${COUNT}

# Set domain's vcpu and memory
DOM_VCPU="1"
DOM_MEM="1024"

# Add domain name into the kv store
kvset $DOM_NAME "1"

#<<"COMMENT"
# Create directory containing Dom
mkdir ${DOM_NAME}

CURRENT_PATH=`pwd`
# Master domain's path
MASTER_PATH="${CURRENT_PATH}/${TEMPLATE_PATH}"
# App domains' path
DOM_PATH="${CURRENT_PATH}/${DOM_NAME}"

# Copy snapshots of images
qemu-img create -f qcow2 -b ${MASTER_PATH}/disk.qcow2 ${DOM_PATH}/${DOM_NAME}.qcow2
qemu-img create -f qcow2 -b ${MASTER_PATH}/swap.qcow2 ${DOM_PATH}/${DOM_NAME}_swap.qcow2

# Create config file
/bin/cat > ${DOM_PATH}/${DOM_NAME}.cfg << EOF
#
# Configuration file for the Xen instance debian1, created
# by xen-tools 4.7 on Wed Oct  4 11:40:53 2017.
#

#
#  Kernel + memory size
#
kernel      = '${MASTER_PATH}/vmlinuz-4.18.0-041800-generic'
extra       = 'elevator=noop'
ramdisk     = '${MASTER_PATH}/initrd.img-4.18.0-041800-generic'

vcpus       = '$DOM_VCPU'
memory      = '$DOM_MEM'

#
#  Disk device(s).
#
root        = '/dev/xvda2 ro'
disk        = [
                  'format=qcow2,file:${DOM_PATH}/${DOM_NAME}.qcow2,xvda2,w',
                  'format=qcow2,file:${DOM_PATH}/${DOM_NAME}_swap.qcow2,xvda1,w',
              ]

#
#  Hostname
#
name        = '$DOM_NAME'

#
#  Networking
#
vif = [ 'bridge=xenbr0, vifname=${DOM_VIF}' ]

#
#  Behaviour
#
on_poweroff = 'destroy'
on_reboot   = 'restart'
on_crash    = 'restart'
EOF

# increment count and save in store
COUNT=$((COUNT+1))
kvset count $COUNT

sudo xl create ${DOM_PATH}/${DOM_NAME}.cfg
#COMMENT
