provider "aws" {
  region     = var.region_aws
}

resource "aws_vpc" "vpc_sgw" {                              # VPC
  cidr_block = var.vpc_cidr_block
  tags = {
    Name  = "${var.project_name}-vpc"
    Shift = var.shift
  }
}

resource "aws_subnet" "pubsub_sgw" {                        # pubsub
  vpc_id                  = aws_vpc.vpc_sgw.id
  availability_zone       = var.azone[0]
  cidr_block              = var.pubsubnet
  map_public_ip_on_launch = true
  tags = {
    Name  = "${var.project_name}-pubsub"
    Shift = var.shift
  }
}
resource "aws_subnet" "privsub_sgw" {                        # privsub
  vpc_id                  = aws_vpc.vpc_sgw.id
  availability_zone       = var.azone[0]
  cidr_block              = var.privsubnet
  tags = {
    Name  = "${var.project_name}-privsub"
    Shift = var.shift
  }
}

resource "aws_internet_gateway" "igw_sgw" {                 # IGW
  vpc_id = aws_vpc.vpc_sgw.id
  tags = {
    Name  = "${var.project_name}-igw"
    Shift = var.shift
  }
}

resource "aws_route_table" "pub_rt_sgw" {                   # RTB
  vpc_id = aws_vpc.vpc_sgw.id

  route {
    cidr_block = var.anycidr
    gateway_id = aws_internet_gateway.igw_sgw.id
  }

  tags = {
    Name  = "${var.project_name}-rtb"
    Shift = var.shift
  }
}

resource "aws_security_group" "bastion_host" {              # SG for bastion host
  name        = "${var.project_name}-bastion-host"
  description = "Bastion Host (Linux instance) security group"
  vpc_id      = aws_vpc.vpc_sgw.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.mypublicip]
  }
  egress {
    description = "Connect outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anycidr]
  }

  tags = {
    Name  = "${var.project_name}-bastion-sg"
    Shift = var.shift
  }
}

resource "aws_security_group" "sgw" {                       # SG for Service Gateway
  name        = "${var.project_name}-sgw"
  description = "Service Gateway security group"
  vpc_id      = aws_vpc.vpc_sgw.id

  ingress {
    description = "SSH from same subnet only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.mypublicip, aws_subnet.pubsub_sgw.cidr_block]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  ingress {
    description = "WRS port"
    from_port   = 5274
    to_port     = 5274
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  ingress {
    description = "WRS port"
    from_port   = 5275
    to_port     = 5275
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  ingress {
    description = "FPS port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  ingress {
    description = "Zero Trust Secure Access Onprem port"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pubsub_sgw.cidr_block, aws_subnet.privsub_sgw.cidr_block]
  }
  egress {
    description = "Connect outside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anycidr]
  }

  tags = {
    Name  = "${var.project_name}-sgw-sg"
    Shift = var.shift
  }
}




resource "aws_instance" "bastion_host_sgw" {                    # Bastion Host (Ubuntu Server)
  ami                    = var.ubuntu_ami
  key_name               = var.kp_name
  subnet_id              = aws_subnet.pubsub_sgw.id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  instance_type          = var.bh_instance_type
  root_block_device {
    volume_size = 30
    volume_type = var.volume_type
  }

  tags = {
    Name  = "${var.project_name}-bastion-host"
    Shift = var.shift
  }
}

resource "aws_instance" "sgw" {                                 # SGW (AL2)
  ami                    = var.sgw_ami 
  key_name               = var.kp_name
  subnet_id              = aws_subnet.pubsub_sgw.id
  vpc_security_group_ids = [aws_security_group.sgw.id]
  instance_type          = var.sgw_instance_type
  associate_public_ip_address = false

  root_block_device {
    volume_size = 200
    volume_type = var.volume_type
  }

  tags = {
    Name  = "${var.project_name}-sgw-server"
    Shift = var.shift
  }
}