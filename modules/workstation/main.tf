terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
  }
}

resource "google_compute_disk" "boot_disk" {
  name        = join("-", [var.name, "boot", "disk"])
  description = "Data disk for the workstation."

  image                     = "ubuntu-2204-lts"
  size                      = 30 # 30*0.04$ = 1.20$ per month, for I/O performance see: https://cloud.google.com/compute/docs/disks/performance
  type                      = "pd-standard"
  physical_block_size_bytes = 4096

  disk_encryption_key {
    kms_key_self_link = var.kms_key
  }
}

resource "google_compute_resource_policy" "backup_policy" {
  name = join("-", [var.name, "backup", "policy"])

  snapshot_schedule_policy {
    schedule {
      weekly_schedule {
        day_of_weeks {
          start_time = "19:00"
          day        = "SUNDAY"
        }
      }
    }
    retention_policy {
      max_retention_days = 15
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "backup_policy_attachment" {
  name = google_compute_resource_policy.backup_policy.name
  disk = google_compute_disk.boot_disk.name
  zone = google_compute_disk.boot_disk.zone
}

resource "google_compute_instance" "workstation" {
  name        = var.name
  description = "Workstation instance for ${var.name}"

  zone           = google_compute_disk.boot_disk.zone
  tags           = [var.environment]
  machine_type   = "e2-medium"
  can_ip_forward = false

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  scheduling {
    provisioning_model  = "SPOT"
    on_host_maintenance = "TERMINATE"
    preemptible         = true
    automatic_restart   = false
  }

  boot_disk {
    device_name = google_compute_disk.boot_disk.name
    source      = google_compute_disk.boot_disk.id
    auto_delete = false
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
      nat_ip = google_compute_address.front_nat.address
    }
  }

  metadata = {
    block-project-ssh-keys = true
    ssh-keys               = join(":", [trimspace(var.user.name), trimspace(var.user.key)])
  }

  resource_policies = [var.policy]
}

resource "google_dns_record_set" "frontend" {
  name = "${var.environment}.${var.dns_zone.dns}"
  type = "A"
  ttl  = 300

  managed_zone = var.dns_zone.name

  rrdatas = [google_compute_instance.workstation.network_interface[0].access_config[0].nat_ip]
}

resource "google_compute_address" "front_nat" {
  name         = "front-address"
  description  = "External IP address for the workstation."
  address_type = "EXTERNAL"
}