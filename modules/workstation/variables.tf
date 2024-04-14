variable "name" {
  type        = string
  description = "The name of the workstation."
  nullable    = false
}

variable "environment" {
  type        = string
  description = "The name of the environment."
  nullable    = false
}

variable "service_account" {
  type        = string
  description = "The email for the service account attached to the workstation."
  nullable    = false
}

variable "disk" {
  type        = map(string)
  description = "The disk attached to the workstation."
  nullable    = false
}

variable "subnetwork" {
  type        = string
  description = "The ID of the subnetwork hosting the workstation."
  nullable    = false
}

variable "nat_ip" {
  type        = string
  description = "The IP address for the front NAT of the workstation."
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

variable "policy" {
  type        = string
  description = "The ID of the resource policy for the workstation."
  nullable    = false
}

variable "dns_zone" {
  type        = map(string)
  description = "The DNS zone for the workspace."
  nullable    = false
}