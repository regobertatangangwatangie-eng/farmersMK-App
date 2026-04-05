terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.farmpro.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "farmpro-public-a"
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

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
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
    from_port   = 8080
    to_port     = 8090
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
  subnet_id              = aws_subnet.public_a.id
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
