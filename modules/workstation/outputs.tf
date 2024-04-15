output "nat_ip" {
  value       = google_compute_instance.workstation.network_interface[0].access_config[0].nat_ip
  description = "The public IP address for the front NAT instance."
}