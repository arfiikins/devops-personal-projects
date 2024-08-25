provider "aws" {
  region     = "us-west-1"
}

variable "project_name" {
  description = "Staging Environment"
  default     = "jana-staging"
}

variable "key_name" {
  description = "AWS key pair"
  default     = "jana-kp-staging"
}

data "external" "current_ip" {
  program = ["python3", "${path.module}/get_ip.py"]
}

# VPC deployment
resource "aws_vpc" "vpc_staging" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name        = "${var.project_name}-vpc"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

# Public subnet deployment
resource "aws_subnet" "pub_subnet_staging" {
  vpc_id                  = aws_vpc.vpc_staging.id
  availability_zone       = "us-west-1a"
  cidr_block              = [data.external.current_ip.result["ip"] + "/32"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

# IGW for public subnet 
resource "aws_internet_gateway" "igw_staging" {
  vpc_id = aws_vpc.vpc_staging.id

  tags = {
    Name        = "${var.project_name}-igw"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

# Route Table
resource "aws_route_table" "pub_rt_staging" {
  vpc_id = aws_vpc.vpc_staging.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_staging.id
  }

  tags = {
    Name        = "${var.project_name}-rt"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

resource "aws_main_route_table_association" "main_rt_staging" {
  vpc_id         = aws_vpc.vpc_staging.id
  route_table_id = aws_route_table.pub_rt_staging.id
}

# Key Pair
resource "aws_key_pair" "servers_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/to/public/key-pair.pem.pub")
  tags = {
    Name        = "${var.project_name}-ec2-kp"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

# SG for public instances
resource "aws_security_group" "sg_staging" {
  name        = "${var.project_name}-bastion-host"
  description = "Bastion Host security group"
  vpc_id      = aws_vpc.vpc_staging.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.external.current_ip.result["ip"] + "/32"]
  }
  egress {
    description = "Connect outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}

# Three Staging Ubuntu Servers
resource "aws_instance" "ubuntu_server_staging" {
  count = 3

  ami                    = "ami-0ff591da048329e00" # Ubuntu 24.04
  key_name               = aws_key_pair.servers_key.key_name
  subnet_id              = aws_subnet.pub_subnet_staging.id
  vpc_security_group_ids = [aws_security_group.sg_staging.id]
  instance_type          = "t2.small"
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project_name}-staging"
    Shift       = "ANZ-Shift"
    Environment = "Staging"
  }
}
