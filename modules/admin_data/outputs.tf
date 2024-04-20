output "workspace_name" {
  value       = lower(replace(data.google_folder.workspace_folder.display_name, " Workspace", ""))
  description = "The name of the workspace"
}

output "key_id" {
  value       = data.google_kms_crypto_key.symmetric_key.id
  description = "The ID of the symmetric crypto key for the workspace."
}

output "dns" {
  value = {
    name   = data.google_dns_managed_zone.working_zone.name
    domain = data.google_dns_managed_zone.working_zone.dns_name
  }
  description = "The DNS zone boud to the workspace."
}