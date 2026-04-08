###############################################################################
# farmersMK-App — DevOps Starter Infrastructure
# 5 EC2 instances: Ansible · Terraform · Docker · Jenkins · Kubernetes (k3s)
###############################################################################

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
  region = "us-east-1"
}

# ── Latest Amazon Linux 2023 x86_64 AMI ──────────────────────────────────────
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ── SSH Key Pair (your local id_ed25519) ──────────────────────────────────────
resource "aws_key_pair" "farmersmk" {
  key_name   = "farmersmk-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6CD/H2LiHHfctXjyCWZqrR2IxAuB3mmlkcrGI/rxWq SOLUTIONS@DESKTOP-929L5GV"
}

# ── VPC / Subnet / IGW ───────────────────────────────────────────────────────
resource "aws_vpc" "devops" {
  cidr_block           = "10.43.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "farmersmk-devops-vpc" }
}

resource "aws_internet_gateway" "devops" {
  vpc_id = aws_vpc.devops.id
  tags   = { Name = "farmersmk-devops-igw" }
}

resource "aws_subnet" "devops" {
  vpc_id                  = aws_vpc.devops.id
  cidr_block              = "10.43.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "farmersmk-devops-subnet" }
}

resource "aws_route_table" "devops" {
  vpc_id = aws_vpc.devops.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops.id
  }
  tags = { Name = "farmersmk-devops-rt" }
}

resource "aws_route_table_association" "devops" {
  subnet_id      = aws_subnet.devops.id
  route_table_id = aws_route_table.devops.id
}

# ── Security Groups ───────────────────────────────────────────────────────────

# Shared SSH for all instances
resource "aws_security_group" "base" {
  name        = "farmersmk-base-sg"
  description = "SSH access for all DevOps instances"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "farmersmk-base-sg" }
}

# Jenkins: port 8080
resource "aws_security_group" "jenkins" {
  name        = "farmersmk-jenkins-sg"
  description = "Jenkins web UI"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins JNLP (VPC only)"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["10.43.0.0/16"]
  }

  tags = { Name = "farmersmk-jenkins-sg" }
}

# Kubernetes: API 6443 + NodePorts
resource "aws_security_group" "kubernetes" {
  name        = "farmersmk-k8s-sg"
  description = "k3s API and NodePort services"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "k3s API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "farmersmk-k8s-sg" }
}

# Docker: private registry port 5000 (VPC-internal only)
resource "aws_security_group" "docker" {
  name        = "farmersmk-docker-sg"
  description = "Docker private registry VPC-internal"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "Docker registry"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["10.43.0.0/16"]
  }

  tags = { Name = "farmersmk-docker-sg" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANCE 1 — Ansible (t3.micro)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_instance" "ansible" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.farmersmk.key_name
  subnet_id              = aws_subnet.devops.id
  vpc_security_group_ids = [aws_security_group.base.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y python3 python3-pip git unzip
    python3 -m pip install --upgrade pip
    python3 -m pip install ansible boto3 botocore
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install
    mkdir -p /opt/farmersmk/ansible
    echo "farmersmk | ANSIBLE ready" > /etc/motd
  USERDATA
  )

  tags = { Name = "farmersmk-ansible", Role = "ansible", Project = "farmersMK" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANCE 2 — Terraform Runner (t3.micro)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_instance" "terraform_runner" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.farmersmk.key_name
  subnet_id              = aws_subnet.devops.id
  vpc_security_group_ids = [aws_security_group.base.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y git unzip
    TF_VERSION="1.7.5"
    curl -fsSL "https://releases.hashicorp.com/terraform/$${TF_VERSION}/terraform_$${TF_VERSION}_linux_amd64.zip" -o /tmp/tf.zip
    unzip -q /tmp/tf.zip -d /usr/local/bin && chmod +x /usr/local/bin/terraform
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install
    mkdir -p /opt/farmersmk/terraform
    echo "farmersmk | TERRAFORM ready" > /etc/motd
  USERDATA
  )

  tags = { Name = "farmersmk-terraform", Role = "terraform", Project = "farmersMK" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANCE 3 — Docker + Private Registry (t3.micro)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_instance" "docker" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.farmersmk.key_name
  subnet_id              = aws_subnet.devops.id
  vpc_security_group_ids = [aws_security_group.base.id, aws_security_group.docker.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y docker git
    systemctl enable --now docker
    usermod -aG docker ec2-user
    COMPOSE_VERSION="v2.24.6"
    curl -fsSL "https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    mkdir -p /opt/farmersmk/registry
    docker run -d --name farmersmk-registry --restart=unless-stopped \
      -p 5000:5000 -v /opt/farmersmk/registry:/var/lib/registry registry:2
    echo "farmersmk | DOCKER ready | registry :5000" > /etc/motd
  USERDATA
  )

  tags = { Name = "farmersmk-docker", Role = "docker", Project = "farmersMK" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANCE 4 — Jenkins (t3.small — needs more RAM for JVM)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.farmersmk.key_name
  subnet_id              = aws_subnet.devops.id
  vpc_security_group_ids = [aws_security_group.base.id, aws_security_group.jenkins.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y java-17-amazon-corretto git docker fontconfig
    systemctl enable --now docker
    wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    dnf install -y jenkins
    mkdir -p /etc/systemd/system/jenkins.service.d
    cat > /etc/systemd/system/jenkins.service.d/override.conf <<'OVERRIDE'
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Xms256m -Xmx768m"
OVERRIDE
    usermod -aG docker jenkins
    systemctl daemon-reload
    systemctl enable --now jenkins
    echo "farmersmk | JENKINS ready | UI :8080" > /etc/motd
  USERDATA
  )

  tags = { Name = "farmersmk-jenkins", Role = "jenkins", Project = "farmersMK" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANCE 5 — Kubernetes / k3s (t3.small)
# ═══════════════════════════════════════════════════════════════════════════════
resource "aws_instance" "kubernetes" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.farmersmk.key_name
  subnet_id              = aws_subnet.devops.id
  vpc_security_group_ids = [aws_security_group.base.id, aws_security_group.kubernetes.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y curl git
    curl -sfL https://get.k3s.io | sh -s - \
      --write-kubeconfig-mode 644 \
      --disable traefik \
      --disable metrics-server
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /etc/profile.d/k3s.sh
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    mkdir -p /opt/farmersmk/k8s
    echo "farmersmk | KUBERNETES (k3s) ready | API :6443" > /etc/motd
  USERDATA
  )

  tags = { Name = "farmersmk-kubernetes", Role = "kubernetes", Project = "farmersMK" }
}
