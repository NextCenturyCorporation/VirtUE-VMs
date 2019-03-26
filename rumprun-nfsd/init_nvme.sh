#!/bin/sh

STORAGE="/dev/nvme1n1"

DIRECTORY=`dirname $0`

if [ -e "/nvme_initialized" ]; then
echo "fail: ${STORAGE} is already initialized"
exit 1
fi

if [ -e ${STORAGE} ]; then
cd "${DIRECTORY}"
#sudo mkfs.ext3 -F ${STORAGE}
sudo mkdir _tmp
sudo mount ${STORAGE} ./_tmp
sudo mkdir -p ./_tmp/nfs
sudo mkdir -p ./_tmp/var/db
sudo touch ./_tmp/var/db/mountdtab
sudo umount ./_tmp
sudo rmdir _tmp
sudo touch /nvme_initialized
sudo sync
(cd /home/ec2-user/rumprun/nfsd && sudo ./start_persistent_storage.sh &)
else
echo "fail: cannot find ${STORAGE}"
exit 1
fi
