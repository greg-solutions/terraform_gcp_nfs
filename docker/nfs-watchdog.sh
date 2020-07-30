#!/bin/bash

# Setting 'unofficial Bash Strict Mode' as described here: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'
NFS_SHARE_NAME="/nfsshare"

timestamp(){
  date '+%Y-%m-%d %H:%M:%S'
}

echoerror()
{
  (>&2 echo "[!][$(timestamp)] Error! $1")
}

# Check required variables
! [[ -d "$NFS_SHARE_NAME" ]] && echoerror "Volume is not mapped!" && exit 1
[[ -z "$GOOGLE_DISK_ID" ]] && echoerror "Variable GOOGLE_DISK_ID is not set" && exit 1
[[ -z "$GOOGLE_PROJECT_NAME" ]] && echoerror "Variable GOOGLE_PROJECT_NAME is not set" && exit 1
[[ -z "$SERVICE_ACC_KEY_B64" ]] && echoerror "Variable SERVICE_ACC_KEY_B64 is not set" && exit 1

# Check and override default values
[[ -z "$CHECK_INTERVAL_MINUTES" ]] && check_interval_minutes=10 || check_interval_minutes="$CHECK_INTERVAL_MINUTES"
[[ -z "$THRESHOLD" ]] && threshold=80 || threshold="$THRESHOLD"
[[ -z "$INCREASE_STEP_GB" ]] && increase_step_gb=10 || increase_step_gb="$INCREASE_STEP_GB"

# Make sure we react to these signals by running stop() when we see them - for clean shutdown
# And then exiting
trap "stop; exit 0;" SIGTERM SIGINT

stop()
{
  # We're here because we've seen SIGTERM, likely via a Docker stop command or similar
  # Let's shutdown cleanly
  echo "[+][$(timestamp)] Terminated"
  exit
}

# Authenticate Google Cloud SDK CLI
## Decode key and set permissions
echo "$SERVICE_ACC_KEY_B64" | base64 -d > key.json
chmod 600 key.json

gcloud config set project "$GOOGLE_PROJECT_NAME"
gcloud auth activate-service-account --key-file=key.json

# self link parsing:
# example of self link
# https://www.googleapis.com/compute/v1/projects/lol-kek/zones/europe-west6-a/disks/nfs-disk
google_zone=$(echo "$GOOGLE_DISK_ID" | awk -F/ '{print $(NF-2)}')
local_disk_name=$(mount | grep "$NFS_SHARE_NAME" | awk '{print $9}')
google_disk_name=$(echo "$GOOGLE_DISK_ID" | awk -F/ '{print $NF}')

# Monitor the disk, main loop
while true;
do
  disk_size=$(( $(lsblk $local_disk_name -b -o SIZE | tail -n1) / 1000000000 ))
  disk_fill_pcent=$(df "$NFS_SHARE_NAME" | tail -n1 | awk '{print $5}' | grep -Eo "[0-9]+")
  if [ "$disk_fill_pcent" -ge "$threshold" ]; then
    disk_size=$((disk_size + increase_step_gb))
    echo "[~][$(timestamp)] Starting to resize disk by +${INCREASE_STEP_GB}GB"
    gcloud compute disks resize $google_disk_name --zone=$google_zone --quiet --size=$disk_size
    ! [[ $? -eq 0 ]] && echoerror "Error caused by gcloud" && exit 1
    resize2fs $local_disk_name
    echo "[+][$(timestamp)] Resized disk. New size is $disk_size"
  else
    echo "[+][$(timestamp)] Disk capacity is below the threshold"
  fi
  sleep "${check_interval_minutes}m"
done

sleep 1
exit 1