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

locals {
  apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com"
  ]
  // Default IP address range for the worksapce network
  base_cidr_block = "10.1.0.0/27"
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
  project_id = join("-", [terraform.workspace, random_string.random.result])
  folder_id  = var.folder
  labels = {
    environment = terraform.workspace
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

resource "google_compute_network" "network" {
  project     = google_project.environment_project.project_id
  name        = join("-", [terraform.workspace, "network"])
  description = "Main network for the workspace"

  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_compute_subnetwork" "subnetwork" {
  project     = google_project.environment_project.project_id
  name        = join("-", ["workstations", "subnet"])
  description = "Subnetwork hosting workstation instances"

  network       = google_compute_network.network.id
  ip_cidr_range = cidrsubnet(local.base_cidr_block, 2, 0)
}

resource "google_compute_route" "default_route" {
  project     = google_project.environment_project.project_id
  name        = join("-", ["from", terraform.workspace, "to", "internet"])
  description = "Default route from the workspace network to the internet"

  network          = google_compute_network.network.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  tags             = [terraform.workspace]
}

resource "google_compute_router" "default_router" {
  project     = google_project.environment_project.project_id
  name        = join("-", [terraform.workspace, "router"])
  description = "Default router for the workspace"

  network = google_compute_network.network.id
}

resource "google_compute_router_nat" "default_gateway" {
  project = google_project.environment_project.project_id
  name    = join("-", [terraform.workspace, "nat", "gateway"])

  router                             = google_compute_router.default_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "to_front" {
  project     = google_project.environment_project.project_id
  name        = join("-", ["allow", "from", "any", "to", terraform.workspace, "tcp", "22"])
  description = "Allow requests from the internet to the ${terraform.workspace} packer instance."

  network   = google_compute_network.network.id
  direction = "INGRESS"
  priority  = 10

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  #TODO: modify with restrictive IP range
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [terraform.workspace]
}

resource "google_storage_bucket" "environment_bucket" {
  name                        = join("-", [terraform.workspace, random_string.random.result])
  location                    = var.region
  project                     = google_project.environment_project.project_id
  force_destroy               = false
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  labels = {
    environment = terraform.workspace
  }
  depends_on = [
    google_project_service.service["storage.googleapis.com"]
  ]
}

resource "google_service_account" "environment_account" {
  account_id   = join("-", [terraform.workspace, "admin"])
  display_name = join(" ", [title(terraform.workspace), "Admin", "Service", "Account"])
  description  = "This service account has full acces to environment project."
  project      = google_project.environment_project.project_id
}

resource "google_storage_bucket_iam_member" "workspace_bucket_editor" {
  bucket = google_storage_bucket.environment_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.environment_account.email}"
}

resource "google_storage_bucket_iam_member" "environment_bucket_owner" {
  bucket = google_storage_bucket.environment_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.environment_account.email}"
}

resource "google_project_iam_member" "environment_compute_admins" {
  project = google_project.environment_project.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.environment_account.email}"
}