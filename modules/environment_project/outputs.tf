output "compute_zones" {
  value       = data.google_compute_zones.available.names
  description = "The names of the available compute zones for the project."
}

output "project_id" {
  value       = google_project.environment_project.project_id
  description = "The ID of the environment project created."
}