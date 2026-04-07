output "server_public_ips" {
  description = "Public IPs of FarmersMK servers"
  value       = aws_instance.FarmersMK[*].public_ip
}

output "server_public_dns" {
  description = "Public DNS records for FarmersMK servers"
  value       = aws_instance.FarmersMK[*].public_dns
}

output "vpc_id" {
  description = "FarmersMK VPC ID"
  value       = aws_vpc.FarmersMK.id
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}

output "ansible_inventory_content" {
  description = "Generated Ansible inventory content"
  value       = local_file.ansible_inventory.content
}
