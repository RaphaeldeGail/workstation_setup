terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
  }
}

resource "google_compute_instance" "workstation" {
  name        = var.name
  description = "Workstation instance for ${var.name}"

  zone           = var.disk.zone
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
    device_name = var.disk.name
    source      = var.disk.id
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