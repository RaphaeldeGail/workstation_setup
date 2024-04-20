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
  default_labels = {
    environment = local.environment
  }
}

provider "google" {
  alias   = "environment"
  region  = var.region
  zone    = module.environment_project.compute_zones[0]
  project = module.environment_project.project_id
  default_labels = {
    environment = local.environment
  }
}

provider "random" {
}

module "admin_data" {
  source = "./modules/admin_data"

  folder = var.folder
  region = var.region
}

locals {
  apis = [
    "iam.googleapis.com",
    "compute.googleapis.com"
  ]
  environment = lower(terraform.workspace)
  name        = join("-", [local.environment, module.admin_data.workspace_name])
}

module "environment_project" {
  source = "./modules/environment_project"

  name            = local.name
  folder          = var.folder
  billing_account = var.billing_account
  apis            = toset(local.apis)
  exec_group      = var.exec_group
  key_id          = module.admin_data.key_id
}

module "workstation" {
  source = "github.com/RaphaeldeGail/legendary-workstation?ref=feature%2Fmanage-workstation"
  providers = {
    google = google.environment
  }

  user    = var.user
  kms_key = module.admin_data.key_id

  depends_on = [
    module.environment_project
  ]
}

resource "google_dns_record_set" "frontend" {
  name = "${local.environment}.${module.admin_data.dns.domain}"
  type = "A"
  ttl  = 300

  managed_zone = module.admin_data.dns.name

  rrdatas = [
    module.workstation.nat_ip
  ]
}

resource "google_storage_bucket_iam_member" "shared_bucket_member" {
  bucket = var.bucket
  role   = "roles/storage.objectAdmin"
  member = join(":", ["serviceAccount", module.workstation.service_account])
}
