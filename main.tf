resource "google_compute_instance" "instance" {
  machine_type = var.instance_type
  name         = var.instance_name
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      size  = var.node_disk_size
    }
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    network_ip = var.internal_ip
    access_config {
    }
  }
  metadata_startup_script = data.template_file.nfs_startup_script.rendered
  attached_disk {
    source      = var.create_disk ? google_compute_disk.default.0.self_link : var.disk_self_link
    mode        = "READ_WRITE"
    device_name = var.create_disk ? google_compute_disk.default.0.name : var.disk_name
  }
  tags = var.tag

  depends_on = [google_compute_disk.default]
}

# NFS disk watchdog service account
resource "google_project_iam_member" "access_secrets" {
  project = data.google_project.project.project_id
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.nfs_disk_watchdog.email}"
  provider = google-beta

  condition {
    title       = "access-to-nfs-disk-only"
    description = "Access to nfs disk only"
    expression  = "resource.name.endsWith('projects/${data.google_project.project.project_id}/zones/${var.compute_zone}/disks/${var.disk_name}') || resource.name.startsWith('projects/${data.google_project.project.project_id}/zones/${var.compute_zone}/operations')"
  }
}

resource "google_service_account" "nfs_disk_watchdog" {
  account_id   = "nfs-disk-watchdog"
  display_name = "Account to manage NFS disk"
}

resource "google_service_account_key" "nfs_watchdog_access_key" {
  service_account_id = google_service_account.nfs_disk_watchdog.name

  depends_on = [google_service_account.nfs_disk_watchdog]
}
# ^ NFS disk watchdog service account ^

resource "google_compute_disk" "default" {
  count = var.create_disk ? 1 : 0

  name                      = var.disk_name
  type                      = "pd-standard"
  size                      = var.disk_size
  physical_block_size_bytes = var.disk_block_size
}

resource "google_compute_firewall" "nfs_access" {
  name          = "nfs-access"
  network       = var.network
  direction     = "INGRESS"
  priority      = 100
  source_ranges = coalescelist(var.nfs_whitelist, [data.google_compute_subnetwork.ip_cidr.ip_cidr_range])
  allow {
    protocol = "TCP"
    ports    = ["2049"]
  }
  target_tags = var.tag

  depends_on = [google_compute_instance.instance]
}

resource "google_compute_firewall" "ssh_access" {
  name          = "ssh-nfs-access"
  network       = var.network
  direction     = "INGRESS"
  priority      = 100
  source_ranges = coalescelist(var.ssh_whitelist, [data.google_compute_subnetwork.ip_cidr.ip_cidr_range])
  allow {
    protocol = "TCP"
    ports    = ["22"]
  }
  target_tags = var.tag

  depends_on = [google_compute_instance.instance]
}

resource "google_compute_resource_policy" "disk_snapshot" {
  count = var.enable_snapshot ? 1 : 0

  name = var.snapshot_policy_name
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = var.snapshot_period_days
        start_time    = var.snapshot_start_time
      }
    }
    retention_policy {
      max_retention_days    = var.snapshot_max_retention_days
      on_source_disk_delete = var.snapshot_after_deleting_disk
    }
    snapshot_properties {
      labels            = var.snapshot_labels
      storage_locations = var.snapshot_storage_location
      guest_flush       = true
    }
  }
}
resource "google_compute_disk_resource_policy_attachment" "attachment" {
  count = var.enable_snapshot ? 1 : 0

  name = google_compute_resource_policy.disk_snapshot.0.name
  disk = var.disk_name
}