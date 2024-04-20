terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
  }
}

locals {
  workspace = lower(replace(data.google_folder.workspace_folder.display_name, " Workspace", ""))
}

data "google_folder" "workspace_folder" {
  folder = var.folder
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
  name = "${local.workspace}-public-zone"
}