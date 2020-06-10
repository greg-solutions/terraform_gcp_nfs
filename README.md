## GCP NFS instance

### Step to resize disk:
    1. Change size in terraform variable
    2. Connect to NFS instance, and push this command:
        sudo resize2fs /dev/sdb
