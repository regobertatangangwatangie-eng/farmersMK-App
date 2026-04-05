variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AWS availability zone for subnet"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.42.1.0/24"
}

variable "ami_id" {
  description = "EC2 AMI ID (Amazon Linux 2023 recommended)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_count" {
  description = "Number of app servers"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Name of existing AWS key pair"
  type        = string
}

variable "ssh_cidrs" {
  description = "Allowed CIDRs for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
