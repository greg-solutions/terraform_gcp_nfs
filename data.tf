data google_compute_subnetwork "ip_cidr"{
  name = var.subnet
}

data "google_project" "project" {
}

data "template_file" "nfs_startup_script" {
  template = file("${path.module}/startup.sh")
  vars = {
    watchdog_service_acc_key_b64 = google_service_account_key.nfs_watchdog_access_key.private_key,
    google_project_name          = data.google_project.project.project_id,
    google_disk_id               = var.create_disk ? google_compute_disk.default.0.self_link : var.disk_self_link,
    check_interval_minutes       = var.nfs_watchdog_check_interval_minutes,
    custom_threshold             = var.nfs_watchdog_custom_threshold,
    custom_incr_step             = var.nfs_watchdog_custom_incr_step
  }
}