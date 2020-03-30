variable "network" {
  description = "(Required) Network where instance will launch"
}
variable "subnet" {
  description = "(Required) Subnet where instance will launch"
}
variable "instance_name" {
  description = "(Optional) Custom instance name"
  default = "nfs-instance"
}
variable "instance_type" {
  description = "(Optional) Custom instance type(size)"
  default = "n1-standard-1"
}
variable "disk_name" {
  description = "(Optional) Custom disk name"
  default = "nfs-disk"
}
variable "disk_size" {
  description = "(Optional) Custom disk size"
  default = 10
}
variable "disk_block_size" {
  description = "(Optional) Custom disk block size"
  default = 4096
}
variable "nfs_whitelist" {
  description = "(Optional) Access to nfs. CIDR IP whitelist. Default is subnet addresses"
  default = []
}
variable "ssh_whitelist" {
  description = "(Optional) Access to ssh. CIDR IP whitelist. Default is subnet addresses"
  default = []
}
variable "tag" {
  description = "(Optional) Custom tag for instance & firewall rules"
  default = ["nfs"]
}
variable "internal_ip" {
  description = "(Optional) Set custom internal ip for instance. Default is dynamic ip address."
  default = null
}