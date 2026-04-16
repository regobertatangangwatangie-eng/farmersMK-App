provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/28" # 16 IPs, 12 usable
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "farmersmk-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/29" # 8 IPs, 5 usable
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "farmersmk-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.8/29" # 8 IPs, 5 usable
  availability_zone = "us-east-1a"
  tags = {
    Name = "farmersmk-private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "farmersmk-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "farmersmk-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
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
}

resource "aws_instance" "bastion" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "public" {
  count         = 3
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "public-instance-${count.index + 1}"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow all outbound"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private" {
  count         = 2
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = "t3.micro"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "private-instance-${count.index + 1}"
  }
}
