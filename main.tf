resource "google_compute_instance" "instance" {
  machine_type = var.instance_type
  name = var.instance_name
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      size = var.disk_size
    }
  }
  network_interface {
    network = var.network
    subnetwork = var.subnet
    network_ip = var.internal_ip
    access_config {
    }
  }
  metadata_startup_script = file("${path.module}/startup.sh")
  attached_disk {
    source = google_compute_disk.default.self_link
    mode = "READ_WRITE"
    device_name = google_compute_disk.default.name
  }
  tags = var.tag
}

resource "google_compute_disk" "default" {
  name  = var.disk_name
  type  = "pd-standard"
  size = var.disk_size
  physical_block_size_bytes = var.disk_block_size
}

data google_compute_subnetwork "ip_cidr"{
  name = var.subnet
}

resource "google_compute_firewall" "nfs_access" {
  name = "nfs-access"
  network = var.network
  direction = "INGRESS"
  priority = 100
  source_ranges = coalescelist(var.nfs_whitelist, [data.google_compute_subnetwork.ip_cidr.ip_cidr_range])
  allow {
    protocol = "TCP"
    ports = ["2049"]
  }
  target_tags = var.tag
}

resource "google_compute_firewall" "ssh_access" {
  name = "ssh-nfs-access"
  network = var.network
  direction = "INGRESS"
  priority = 100
  source_ranges = coalescelist(var.ssh_whitelist, [data.google_compute_subnetwork.ip_cidr.ip_cidr_range])
  allow {
    protocol = "TCP"
    ports = ["22"]
  }
  target_tags = var.tag
}