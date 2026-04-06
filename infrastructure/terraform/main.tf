terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "farmpro" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "farmpro-vpc"
  }
}

resource "aws_internet_gateway" "farmpro" {
  vpc_id = aws_vpc.farmpro.id

  tags = {
    Name = "farmpro-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.farmpro.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "farmpro-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.farmpro.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.farmpro.id
  }

  tags = {
    Name = "farmpro-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "farmpro" {
  name        = "farmpro-sg"
  description = "Security group for FarmPro servers"
  vpc_id      = aws_vpc.farmpro.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8095
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "farmpro-sg"
  }
}

resource "aws_instance" "farmpro" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.farmpro.id]

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              dnf -y update || yum -y update
              dnf -y install docker git || yum -y install docker git
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "farmpro-server-${count.index + 1}"
    Role = "farmpro-app"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
            [farmpro]
            server1 ansible_host=${aws_instance.farmpro[0].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/root/.ssh/ansible_key
            server2 ansible_host=${aws_instance.farmpro[1].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/root/.ssh/ansible_key
            EOT
}
