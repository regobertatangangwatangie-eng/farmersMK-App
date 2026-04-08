output "ansible_ip"          { value = aws_instance.ansible.public_ip }
output "terraform_runner_ip" { value = aws_instance.terraform_runner.public_ip }
output "docker_ip"           { value = aws_instance.docker.public_ip }
output "jenkins_ip"          { value = aws_instance.jenkins.public_ip }
output "kubernetes_ip"       { value = aws_instance.kubernetes.public_ip }

output "connection_guide" {
  value = <<-GUIDE
  ── farmersMK DevOps instances ──────────────────────────────────────
  ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.ansible.public_ip}          # Ansible
  ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.terraform_runner.public_ip}  # Terraform
  ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.docker.public_ip}            # Docker  (:5000 registry)
  ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.jenkins.public_ip}           # Jenkins (:8080)
  ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.kubernetes.public_ip}        # k3s     (:6443)
  ────────────────────────────────────────────────────────────────────
  GUIDE
}
