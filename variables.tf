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