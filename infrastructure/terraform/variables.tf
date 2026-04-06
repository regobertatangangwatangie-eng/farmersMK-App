variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "AWS availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
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
  description = "Number of app servers (fixed to 2 for active/active app nodes)"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count == 2
    error_message = "instance_count must be exactly 2."
  }
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
