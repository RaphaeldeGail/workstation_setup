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
  project = var.admin_project
  default_labels = {
    environment = local.environment
  }
}

provider "random" {
}

module "workspace_data" {
  source = "github.com/RaphaeldeGail/workspace-data?ref=main"

  workspace = var.name
  region    = var.region
}

locals {
  environment = lower(terraform.workspace)
  name        = join("-", [local.environment, var.name])
}

module "environment_project" {
  source = "github.com/RaphaeldeGail/environment-project?ref=main"

  name            = local.name
  folder          = var.workspace_folder
  billing_account = var.billing_account
  apis = [
    {
      name = "compute.googleapis.com"
      service_agent = {
        email = "service-PROJECT-NUMBER@compute-system.iam.gserviceaccount.com"
        role  = "roles/compute.serviceAgent"
      }
    }
  ]
  bindings = [
    {
      role = "roles/compute.instanceAdmin.v1"
      members = [
        "group:${var.exec_group}",
      ]
    }
  ]
  kms_key = module.workspace_data.kms_key
}

# module "workstation" {
#   source = "github.com/RaphaeldeGail/legendary-workstation?ref=feature%2Fmanage-workstation"
#   providers = {
#     google = google.environment
#   }

#   user    = var.user
#   kms_key = module.admin_data.key_id

#   depends_on = [
#     module.environment_project
#   ]
# }

# resource "google_dns_record_set" "frontend" {
#   name = "${local.environment}.${module.admin_data.dns.domain}"
#   type = "A"
#   ttl  = 300

#   managed_zone = module.admin_data.dns.name

#   rrdatas = [
#     module.workstation.nat_ip
#   ]
# }

# resource "google_storage_bucket_iam_member" "shared_bucket_member" {
#   bucket = var.bucket
#   role   = "roles/storage.objectAdmin"
#   member = join(":", ["serviceAccount", module.workstation.service_account])
# }
