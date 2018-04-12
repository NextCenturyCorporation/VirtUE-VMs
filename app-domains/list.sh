#!/bin/bash

# simple key-value store for Domain names
source kv-bash/kv-bash

OUTPUT=`kvlist`
if [ "$OUTPUT" = "" ]
then
	echo "No domains"

else
	for DOM_NAME in `kvlist | awk '{print $1}'`
	do
		echo "Domain name: $DOM_NAME"
	done
fi
