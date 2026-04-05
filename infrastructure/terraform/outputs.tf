output "server_public_ips" {
  description = "Public IPs of FarmPro servers"
  value       = aws_instance.farmpro[*].public_ip
}

output "server_public_dns" {
  description = "Public DNS records for FarmPro servers"
  value       = aws_instance.farmpro[*].public_dns
}

output "vpc_id" {
  description = "FarmPro VPC ID"
  value       = aws_vpc.farmpro.id
}
