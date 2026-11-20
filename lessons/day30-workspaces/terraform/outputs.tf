output "environment" {
  description = "Environment selected by the Terraform workspace."
  value       = terraform.workspace
}

output "application_url" {
  description = "HTTP URL of the application load balancer."
  value       = module.app.application_url
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer."
  value       = module.app.load_balancer_dns_name
}

output "application_data_bucket_name" {
  description = "Name of the private, versioned application data bucket."
  value       = module.storage.bucket_name
}
