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
  wrk_name = lower(replace(data.google_folder.workspace_folder.display_name, " Workspace", ""))
  name = join("-", [terraform.workspace, local.wrk_name])
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

resource "google_service_account" "environment_account" {
  account_id   = join("-", [terraform.workspace, "admin"])
  display_name = join(" ", [title(terraform.workspace), "Admin", "Service", "Account"])
  description  = "This service account has full acces to environment project."
  project      = google_project.environment_project.project_id
}

resource "google_project_iam_binding" "environment_editors" {
  project = google_project.environment_project.project_id
  role    = "roles/editor"

  members = [
    "serviceAccount:${google_service_account.environment_account.email}",
    "group:${var.exec_group}"
  ]
}

resource "google_service_account_iam_binding" "workld_user" {
  service_account_id = google_service_account.environment_account.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    var.principal_set,
  ]
}