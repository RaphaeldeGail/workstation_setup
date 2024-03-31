variable "billing_account" {
  type        = string
  description = "The ID of the billing account used for the workspace. \"Billing account User\" permissions are required to execute module."
  nullable    = false
}

variable "folder" {
  type        = number
  description = "The ID of the Workspace Folder."
  nullable    = false
}

variable "project" {
  type        = string
  description = "The ID of the admin project."
  nullable    = false
}

variable "region" {
  type        = string
  description = "Geographical *region* for Google Cloud Platform."
  nullable    = false
}

variable "exec_group" {
  type        = string
  description = "The email address of the Google group with exectuive usage for the project."
  nullable    = false
}