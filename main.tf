resource "google_compute_instance" "instance" {
  machine_type = var.instance_type
  name = var.instance_name
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      size = var.node_disk_size
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

  depends_on = [google_compute_disk.default]
}

resource "google_compute_disk" "default" {
  name  = var.disk_name
  type  = "pd-standard"
  size = var.disk_size
  physical_block_size_bytes = var.disk_block_size
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

  depends_on = [google_compute_instance.instance]
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

  depends_on = [google_compute_instance.instance]
}

resource "google_compute_resource_policy" "disk_snapshot" {
  count = var.enable_snapshot ? 1 : 0
  name   = var.snapshot_policy_name
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = var.snapshot_period_days
        start_time     = var.snapshot_start_time
      }
    }
    retention_policy {
      max_retention_days    = var.snapshot_max_retention_days
      on_source_disk_delete = var.snapshot_after_deleting_disk
    }
    snapshot_properties {
      labels = var.snapshot_labels
      storage_locations = var.snapshot_storage_location
      guest_flush       = true
    }
  }
}
resource "google_compute_disk_resource_policy_attachment" "attachment" {
  count = var.enable_snapshot ? 1 : 0
  name = google_compute_resource_policy.disk_snapshot.0.name
  disk = google_compute_disk.default.name
}