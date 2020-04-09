data google_compute_subnetwork "ip_cidr"{
  name = var.subnet
  depends_on = [google_compute_instance.instance]
}