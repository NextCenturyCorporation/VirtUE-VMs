#!/bin/bash

# simple key-value store for Domain names
source kv-bash/kv-bash

if [ "$#" = "0" ]
then
	echo "Domain name should be specified"
	exit

elif [ "$#" = "1" ]
then
	if [ "$1" = "all" ]
	then
		for DOM_NAME in `kvlist | awk '{print $1}'`
		do			
			rm -rf "$DOM_NAME"
		done
		
		# Clear the kv store
		kvclear
		
		echo "All domains removed"
		exit
	fi
fi

for DOM_NAME in "$@"
do
	RESULT=`kvget $DOM_NAME`
	if [ "$RESULT" = "1" ]
	then
		kvdel "$DOM_NAME"
		rm -rf "$DOM_NAME"
		echo "$DOM_NAME is removed"
	else
		echo "$DOM_NAME doesn't exist"
		continue
	fi
done

