# NFS share disk watchdog

A handy NFS (google disk) Watchdog container, checks if disk is not full and scales it up, using google cloud sdk, if it's filling up over the threshold.

Required arguments:
- Map volume: 
    - `MNT_DIRECTORY:/nfsshare`
- Env. variables:
    - `GOOGLE_DISK_ID`
    - `GOOGLE_PROJECT_NAME`
    - `SERVICE_ACC_KEY_B64`

Usage example:
```
  docker run -d --restart unless-stopped \
    --name nfs-watchdog \
    --privileged \
    -v MNT_DIRECTORY:/nfsshare \
    -e GOOGLE_DISK_ID="google_disk_self_link" \
    -e GOOGLE_PROJECT_NAME="Google Project Name" \
    -e SERVICE_ACC_KEY_B64="base64encodedkey" \
    -e CHECK_INTERVAL_MINUTES=10 \
    -e THRESHOLD=80 \
    -e INCREASE_STEP_GB=10 \
    --log-opt max-size=1024m \
    --log-opt max-file=3 \
    verbalius/nfs-watchdog
```