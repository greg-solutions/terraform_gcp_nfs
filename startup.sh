#! /bin/bash

DISK="sdb"
MNT_DIRECTORY="/mnt/sdb"
FILE_CHECK="/startup-done.txt"

# Checking for fisrt boot
if [ ! -f $FILE_CHECK ]; then
  # Install Docker
  apt install apt-transport-https ca-certificates curl software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install docker-ce -y
  usermod -aG docker ubuntu

  # Mount disk
  mkdir $MNT_DIRECTORY
  if lsblk --output NAME,FSTYPE | grep $DISK | grep -q ext4 ; then
    # Disk is ext4. Mount.
    mount -o discard,defaults /dev/$DISK $MNT_DIRECTORY
  else
    # Disk is not ext4. Format & Mount
    mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DISK
    mount -o discard,defaults /dev/$DISK $MNT_DIRECTORY
  fi

  # Permission set
  chmod a+w $MNT_DIRECTORY

  #Start docker container
  docker run -d --restart unless-stopped --name nfs --privileged -v $MNT_DIRECTORY:/nfsshare -e SHARED_DIRECTORY=/nfsshare -p 2049:2049 --log-opt max-size=1024m --log-opt max-file=3 itsthenetwork/nfs-server-alpine:12

  touch $FILE_CHECK
else
  # Permission set
  chmod a+w $MNT_DIRECTORY

  # Mount disk
  mount -o discard,defaults /dev/$DISK $MNT_DIRECTORY

  # Restart stoped container
  docker restart $(docker ps -a -q)
fi

while ! mount | grep "on $MNT_DIRECTORY type" > /dev/null; do
    sleep 1
    mount -o discard,defaults /dev/$DISK $MNT_DIRECTORY
done