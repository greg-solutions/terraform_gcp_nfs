variable "network" {
  type = string
  description = "(Required) Network where instance will launch"
}
variable "subnet" {
  type = string
  description = "(Required) Subnet where instance will launch"
}
variable "instance_name" {
  description = "(Optional) Custom instance name"
  default = "nfs-server"
}
variable "instance_type" {
  type = string
  description = "(Optional) Custom instance type(size)"
  default = "n1-standard-1"
}
variable "disk_name" {
  type = string
  description = "(Optional) Custom disk name"
  default = "nfs-disk"
}
variable "node_disk_size" {
  type = number
  description = "(Optional) Custom disk size for node"
  default = 10
}
variable "disk_size" {
  type = number
  description = "(Optional) Custom disk size for nfs"
  default = 10
}
variable "disk_block_size" {
  type = number
  description = "(Optional) Custom disk block size"
  default = 4096
}
variable "nfs_whitelist" {
  type = list(string)
  description = "(Optional) Access to nfs. CIDR IP whitelist. Default is subnet addresses"
  default = []
}
variable "ssh_whitelist" {
  type = list(string)
  description = "(Optional) Access to ssh. CIDR IP whitelist. Default is subnet addresses"
  default = []
}
variable "tag" {
  type = list(string)
  description = "(Optional) Custom tag for instance & firewall rules"
  default = ["nfs"]
}
variable "internal_ip" {
  type = string
  description = "(Optional) Set custom internal ip for instance. Default is dynamic ip address."
  default = null
}
variable "enable_snapshot" {
  type = bool
  description = "(Optional) Specify true to enable nfs-disk snapshots creating"
  default = false
}
variable "snapshot_policy_name" {
  type = string
  description = "(Optional) Name of the policy for automatic snapshots of nfs-disk"
  default = "nfs-disk-snapshot-schedule"
}
variable "snapshot_period_days" {
  type = number
  description = "(Optional) Frequently of making automatic snapshots of nfs-disk in days e.g = 1 (each day)"
  default = 1
}
variable "snapshot_start_time" {
  type = string
  description = "(Optional) Time when start creating snapshots of nfs-disk in hours e.g 23:00"
  default = "5:00"
}
variable "snapshot_max_retention_days" {
  type = number
  description = "(Optional) How many days should keep snapshots after creating in day"
  default = 7
}
variable "snapshot_after_deleting_disk" {
  type = string
  description = "(Optional) Action after source disk is deleted, available option KEEP_AUTO_SNAPSHOTS and APPLY_RETENTION_POLICY"
  default = "KEEP_AUTO_SNAPSHOTS"
}
variable "snapshot_labels" {
  type = map(string)
  description = "(Optional) label of the nfs-disk snapshots"
  default = {
       label = "nfs-disk-snapshot"
      }
}
variable "snapshot_storage_location" {
  type = list(string)
  description = "(Required) Location where nfs-disk snapshots should be stored"
  default = null
}