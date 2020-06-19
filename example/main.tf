module "nfs" {
  source = "../"
  network = module.vpc.networks[0]
  subnet = module.vpc.subnetworks_name[0]
  disk_size = 50 #after resize hit following command on nfs instance: resize2fs /dev/sdb
  ssh_whitelist = ["94.12.34.11/32"]
  nfs_whitelist = ["10.0.0.0/16", "23.43.11.234/32"]
  internal_ip = "10.10.0.100"
  snapshot_policy_name = "nfs-disk-snapshot-schedule"
  snapshot_policy_region = "europe-west6"
  snapshot_period_days = 1
  snapshot_start_time = "23:00"
  snapshot_max_retention_days = 7
  snapshot_after_deleting_disk = "KEEP_AUTO_SNAPSHOTS"
  snapshot_storage_location = ["us"]
}