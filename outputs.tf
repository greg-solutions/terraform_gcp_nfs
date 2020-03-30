output "instance_id" {
  value = google_compute_instance.instance.instance_id
}
output "internal_ip" {
  value = google_compute_instance.instance.network_interface[0].network_ip
}
output "external_ip" {
  value = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
}
output "firewall_nfs_id" {
  value = google_compute_firewall.nfs_access.id
}
output "firewall_ssh_id" {
  value = google_compute_firewall.ssh_access.id
}