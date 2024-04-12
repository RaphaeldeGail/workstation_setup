/**
 * # Setup
 * 
 */

terraform {
  required_version = "~> 1.7.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project
}

provider "random" {
}

data "google_folder" "workspace_folder" {
  folder = var.folder
}

locals {
  apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com"
  ]
  // Default IP address range for the worksapce network
  base_cidr_block = "10.1.0.0/27"
  wrk_name        = lower(replace(data.google_folder.workspace_folder.display_name, " Workspace", ""))
  name            = lower(join("-", [terraform.workspace, local.wrk_name]))
}

resource "random_string" "random" {
  length      = 4
  keepers     = null
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  upper       = false
  special     = false
}

resource "google_project" "environment_project" {
  name       = terraform.workspace
  project_id = join("-", [local.name, random_string.random.result])
  folder_id  = var.folder
  labels = {
    environment = lower(terraform.workspace)
  }
  skip_delete = true

  lifecycle {
    ignore_changes = [billing_account]
  }
}

resource "google_billing_project_info" "billing_association" {
  project         = google_project.environment_project.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "service" {
  for_each = toset(local.apis)

  project = google_project.environment_project.project_id
  service = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_service_account" "environment_account" {
  account_id   = join("-", [local.name, "admin"])
  display_name = join(" ", [title(local.name), "Admin", "Service", "Account"])
  description  = "Service account for the environment project."
  project      = google_project.environment_project.project_id
}

resource "google_project_iam_binding" "instance_admins" {
  project = google_project.environment_project.project_id
  role    = "roles/compute.instanceAdmin.v1"

  members = [
    "group:${var.exec_group}"
  ]
}

data "google_kms_key_ring" "key_ring" {
  project  = var.project
  name     = "${local.wrk_name}-keyring"
  location = var.region
}

data "google_kms_crypto_key" "symmetric_key" {
  key_ring = data.google_kms_key_ring.key_ring.id
  name     = "${local.wrk_name}-symmetric-key"
}

resource "google_kms_crypto_key_iam_member" "crypto_compute" {
  crypto_key_id = data.google_kms_crypto_key.symmetric_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${google_project.environment_project.number}@compute-system.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.service["iam.googleapis.com"]
  ]
}

resource "google_compute_network" "network" {
  project      = google_project.environment_project.project_id
  name         = "${local.name}-network"
  description  = "Network for the ${local.name} environment."
  routing_mode = "REGIONAL"

  auto_create_subnetworks         = false
  delete_default_routes_on_create = true

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_compute_subnetwork" "subnetwork" {
  name        = join("-", ["workstations", "subnet"])
  project     = google_project.environment_project.project_id
  description = "Subnetwork hosting workstation instances"

  network       = google_compute_network.network.id
  ip_cidr_range = cidrsubnet(local.base_cidr_block, 2, 0)
}

resource "google_compute_route" "default_route" {
  name        = join("-", ["from", local.name, "to", "internet"])
  description = "Default route from the workspace network to the internet"

  network          = google_compute_network.network.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  tags             = [lower(terraform.workspace)]
}

resource "google_compute_firewall" "default" {
  name          = "user-firewall"
  project       = google_project.environment_project.project_id
  description   = "Only allow connections from user public IP to workstation."
  direction     = "INGRESS"
  priority      = 0
  network       = google_compute_network.network.name
  source_ranges = [var.user.ip]

  target_service_accounts = [ google_service_account.environment_account.email ]

  allow {
    protocol = "tcp"
    ports    = ["22", "8080-8090"]
  }
}

data "google_compute_zones" "available" {
}

resource "google_compute_disk" "boot_disk" {
  project     = google_project.environment_project.project_id
  name        = join("-", [local.name, "boot", "disk"])
  description = "Data disk for the workstation."

  labels = {
    environment = lower(terraform.workspace)
  }

  image                     = "ubuntu-2204-lts"
  size                      = 30 # 30*0.04$ = 1.20$ per month, for I/O performance see: https://cloud.google.com/compute/docs/disks/performance
  type                      = "pd-standard"
  physical_block_size_bytes = 4096
  zone                      = data.google_compute_zones.available.names[0]

  disk_encryption_key {
    kms_key_self_link = data.google_kms_crypto_key.symmetric_key.id
  }

  depends_on = [
    google_kms_crypto_key_iam_member.crypto_compute
  ]
}

resource "google_compute_resource_policy" "shutdown_policy" {
  name = join("-", [local.name, "shutdown", "policy"])
  project = google_project.environment_project.project_id

  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "0 20 * * *"
    }
    time_zone = "Europe/Paris"
  }

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_compute_resource_policy" "backup_policy" {
  name = join("-", [local.name, "backup", "policy"])
  project = google_project.environment_project.project_id

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

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_compute_disk_resource_policy_attachment" "backup_policy_attachment" {
  name = google_compute_resource_policy.backup_policy.name
  disk = google_compute_disk.boot_disk.name
  zone = google_compute_disk.boot_disk.zone
}

resource "google_storage_bucket_iam_member" "shared_bucket_member" {
  bucket = var.bucket
  role   = "roles/storage.objectAdmin"
  member = join(":", ["serviceAccount", google_service_account.environment_account.email])
}

resource "google_compute_instance" "workstation" {
  name        = join("-", [local.name, "workstation"])
  description = "Workstation instance for ${local.name}"

  zone           = google_compute_disk.boot_disk.zone
  tags           = [terraform.workspace]
  machine_type   = "e2-medium"
  can_ip_forward = false

  service_account {
    email  = google_service_account.environment_account.email
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
    subnetwork = google_compute_subnetwork.subnetwork.self_link

    access_config {
      nat_ip = google_compute_address.front_nat.address
    }
  }

  metadata = {
    block-project-ssh-keys = true
    ssh-keys               = join(":", [trimspace(var.user.name), trimspace(var.user.key)])
  }

  resource_policies = [google_compute_resource_policy.shutdown_policy.self_link]

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_compute_address" "front_nat" {
  name         = "front-address"
  description  = "External IP address for the workstation."
  address_type = "EXTERNAL"
  region       = var.region
  project      = google_project.environment_project.project_id
}

data "google_dns_managed_zone" "working_zone" {
  name    = var.dns_zone
  project = var.project
}

resource "google_dns_record_set" "frontend" {
  name = "${terraform.workspace}.${data.google_dns_managed_zone.working_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.working_zone.name

  rrdatas = [google_compute_instance.workstation.network_interface[0].access_config[0].nat_ip]
}