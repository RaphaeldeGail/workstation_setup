terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
  }
}

locals {
  // Default IP address range for the worksapce network
  base_cidr_block = "10.1.0.0/27"
}

resource "google_compute_network" "network" {
  name         = "${var.name}-network"
  description  = "Network for the ${var.name} environment."
  routing_mode = "REGIONAL"

  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnetwork" {
  name        = join("-", ["workstations", "subnet"])
  description = "Subnetwork hosting workstation instances"

  network       = google_compute_network.network.id
  ip_cidr_range = cidrsubnet(local.base_cidr_block, 2, 0)
}

resource "google_compute_route" "default_route" {
  name        = join("-", ["from", var.name, "to", "internet"])
  description = "Default route from the workspace network to the internet"

  network          = google_compute_network.network.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  tags             = [var.name]
}

resource "google_compute_firewall" "default" {
  name          = "user-firewall"
  description   = "Only allow connections from user public IP to workstation."
  direction     = "INGRESS"
  priority      = 0
  network       = google_compute_network.network.name
  source_ranges = [var.user.ip]

  target_service_accounts = [var.service_account]

  allow {
    protocol = "tcp"
    ports    = ["22", "8080-8090"]
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

resource "google_compute_resource_policy" "shutdown_policy" {
  name = join("-", [var.name, "shutdown", "policy"])

  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "0 20 * * *"
    }
    time_zone = "Europe/Paris"
  }
}

resource "google_compute_instance" "workstation" {
  name        = var.name
  description = "Workstation instance for ${var.name}"

  zone           = google_compute_disk.boot_disk.zone
  tags           = [var.name]
  machine_type   = "e2-medium"
  can_ip_forward = false

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  scheduling {
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
    on_host_maintenance         = "TERMINATE"
    preemptible                 = true
    automatic_restart           = false
  }

  boot_disk {
    device_name = google_compute_disk.boot_disk.name
    source      = google_compute_disk.boot_disk.id
    auto_delete = false
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.self_link

    access_config {
      nat_ip = google_compute_address.front_nat.address
    }
  }

  metadata = {
    block-project-ssh-keys = true
    ssh-keys               = join(":", [trimspace(var.user.name), trimspace(var.user.key)])
  }

  resource_policies = [
    google_compute_resource_policy.shutdown_policy.self_link
  ]
}

resource "google_compute_address" "front_nat" {
  name         = "front-address"
  description  = "External IP address for the workstation."
  address_type = "EXTERNAL"
}