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
        email = "service-PROJECT_NUMBER@compute-system.iam.gserviceaccount.com"
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
    },
    {
      role = "roles/editor"
      members = [
        "serviceAccount:${var.admin_account}"
      ]
    }
  ]
}

resource "google_kms_crypto_key_iam_member" "crypto_compute" {
  crypto_key_id = module.workspace_data.kms_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${module.environment_project.project_number}@compute-system.iam.gserviceaccount.com"
}