variable "billing_account" {
  type        = string
  description = "The ID of the billing account used for the workspace. \"Billing account User\" permissions are required to execute module."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the workspace."
  nullable    = false
}

variable "workspace_folder" {
  type        = number
  description = "The ID of the Workspace Folder."
  nullable    = false
}

variable "admin_project" {
  type        = string
  description = "The ID of the admin project."
  nullable    = false
}

variable "region" {
  type        = string
  description = "Geographical *region* for Google Cloud Platform."
  nullable    = false
}

variable "bucket" {
  type        = string
  description = "The name of the administrator bucket."
  nullable    = false
}

variable "exec_group" {
  type        = string
  description = "The email address of the Google group with usage permissions for the workstation."
  nullable    = false
}

variable "admin_account" {
  type        = string
  description = ""
  nullable    = false
}

variable "user" {
  type = object({
    ip   = string
    name = string
    key  = string
  })

  description = "An object declaring a user with access authorization to the workstation."
  nullable    = false
}