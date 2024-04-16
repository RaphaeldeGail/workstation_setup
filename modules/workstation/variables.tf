variable "name" {
  type        = string
  description = "The name of the workstation."
  nullable    = false
}

variable "service_account" {
  type        = string
  description = "The email for the service account attached to the workstation."
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

variable "kms_key" {
  type        = string
  description = "The ID for the KMS key to encrypt disk data."
  nullable    = false
}