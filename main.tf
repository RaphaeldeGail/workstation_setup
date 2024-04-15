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

provider "google" {
  alias   = "environment"
  region  = var.region
  zone    = data.google_compute_zones.available.names[0]
  project = google_project.environment_project.project_id
  default_labels = {
    environment = local.environment
  }
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
  environment = lower(terraform.workspace)
  workspace   = lower(replace(data.google_folder.workspace_folder.display_name, " Workspace", ""))
  name        = join("-", [local.environment, local.workspace])
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
  name       = local.environment
  project_id = join("-", [local.name, random_string.random.result])
  folder_id  = var.folder
  labels = {
    environment = local.environment
  }
  skip_delete = false

  lifecycle {
    ignore_changes = [billing_account]
  }
}

resource "google_billing_project_info" "billing_association" {
  project         = google_project.environment_project.project_id
  billing_account = var.billing_account
}

data "google_compute_zones" "available" {
  project = google_project.environment_project.project_id
}

data "google_kms_key_ring" "key_ring" {
  name     = "${local.workspace}-keyring"
  location = var.region
}

data "google_kms_crypto_key" "symmetric_key" {
  key_ring = data.google_kms_key_ring.key_ring.id
  name     = "${local.workspace}-symmetric-key"
}

data "google_dns_managed_zone" "working_zone" {
  name = var.dns_zone
}

resource "google_storage_bucket_iam_member" "shared_bucket_member" {
  bucket = var.bucket
  role   = "roles/storage.objectAdmin"
  member = join(":", ["serviceAccount", google_service_account.environment_account.email])
}

##### #####

resource "google_project_service" "service" {
  for_each = toset(local.apis)
  provider = google.environment

  service = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_service_account" "environment_account" {
  provider = google.environment

  account_id   = join("-", [local.environment, "admin"])
  display_name = join(" ", [title(local.name), "Admin", "Service", "Account"])
  description  = "Service account for the environment project."
}

resource "google_project_iam_binding" "instance_admins" {
  project = google_project.environment_project.project_id
  role    = "roles/compute.instanceAdmin.v1"

  members = [
    "group:${var.exec_group}",
    "serviceAccount:service-${google_project.environment_project.number}@compute-system.iam.gserviceaccount.com"
  ]

  depends_on = [
    google_project_service.service["iam.googleapis.com"]
  ]
}

resource "google_kms_crypto_key_iam_member" "crypto_compute" {
  crypto_key_id = data.google_kms_crypto_key.symmetric_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${google_project.environment_project.number}@compute-system.iam.gserviceaccount.com"
}

module "workstation" {
  source = "./modules/workstation"
  providers = {
    google = google.environment
  }

  name            = local.name
  environment     = local.environment
  service_account = google_service_account.environment_account.email
  user            = var.user
  kms_key         = data.google_kms_crypto_key.symmetric_key.id

  depends_on = [
    google_project_service.service["compute.googleapis.com"],
    google_project_iam_binding.instance_admins,
    google_kms_crypto_key_iam_member.crypto_compute
  ]
}

resource "google_dns_record_set" "frontend" {
  name = "${local.environment}.${data.google_dns_managed_zone.working_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.working_zone.name

  rrdatas = [
    module.workstation.nat_ip
  ]
}