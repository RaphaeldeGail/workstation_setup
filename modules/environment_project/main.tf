terraform {
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
  name       = title(replace(var.name, "-", " "))
  project_id = join("-", [var.name, random_string.random.result])
  folder_id  = var.folder

  skip_delete = false

  lifecycle {
    ignore_changes = [billing_account]
  }
}

resource "google_billing_project_info" "billing_association" {
  project         = google_project.environment_project.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "service" {
  for_each = var.apis
  project  = google_project.environment_project.project_id

  service = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    google_billing_project_info.billing_association
  ]
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
  crypto_key_id = var.key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${google_project.environment_project.number}@compute-system.iam.gserviceaccount.com"
}

data "google_compute_zones" "available" {
  project = google_project.environment_project.project_id

  depends_on = [
    google_project_service.service["iam.googleapis.com"]
  ]
}