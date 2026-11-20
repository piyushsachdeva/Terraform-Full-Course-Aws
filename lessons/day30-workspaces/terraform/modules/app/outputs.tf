output "application_url" {
  value = "http://${aws_lb.this.dns_name}"
}

output "load_balancer_dns_name" {
  value = aws_lb.this.dns_name
}
