provider "aws" {
  region = var.region
}

# list of variables
variable "region" {}
variable "project_name" {}
variable "vpc_cidr_block" {}
variable "shift" {}
variable "availzone" {}
variable "pubsubnets_cidr" {}
variable "privsubnets_cidr" {}
variable "keypair" {}
variable "all" {}
variable "ubuntu_ami" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "engine_rds" {}
variable "enginev_rds" {}
variable "instance_class_rds" {}
variable "instance_type_ec2" {}
variable "volume_ec2" {}
variable "volumet_instance" {}


# aws resources
resource "aws_vpc" "vpc_2t" {                   # VPC
  cidr_block = var.vpc_cidr_block
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_internet_gateway" "igw_2t" {      # IGW
  vpc_id = aws_vpc.vpc_2t.id
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_subnet" "pub_subnet_1_2t" {         # Pub Subnet 1
  vpc_id = aws_vpc.vpc_2t.id
  cidr_block = var.pubsubnets_cidr[0]
  availability_zone = var.availzone[0]
  map_public_ip_on_launch = true
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_subnet" "pub_subnet_2_2t" {         # Pub Subnet 2
  vpc_id = aws_vpc.vpc_2t.id
  cidr_block = var.pubsubnets_cidr[1]
  availability_zone = var.availzone[1]
  map_public_ip_on_launch = true
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_subnet" "priv_subnet_1_2t" {        # Priv Subnet 1
  vpc_id = aws_vpc.vpc_2t.id
  cidr_block = var.privsubnets_cidr[0]
  availability_zone = var.availzone[0]
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_subnet" "priv_subnet_2_2t" {        # Priv Subnet 2
  vpc_id = aws_vpc.vpc_2t.id
  cidr_block = var.privsubnets_cidr[1]
  availability_zone = var.availzone[1]
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_alb" "alb_2t" {                     # ALB
  name = "${var.project_name}-alb"
  internal = false
  security_groups = [aws_security_group.alb_sg_2t.id]
  subnets = [ aws_subnet.pub_subnet_1_2t, aws_subnet.pub_subnet_2_2t ]
  tags = {
    ProjectName = var.project_name
    Shift = var.shift
  }
}
resource "aws_instance" "pub_ec2_1_2t" {        # EC2 pubsub 1
  ami                    = var.ubuntu_ami # Ubuntu
  key_name               = var.keypair
  subnet_id              = aws_subnet.pub_subnet_1_2t.id
  vpc_security_group_ids = [aws_security_group.pubsubs_sg_2t.id]
  instance_type          = var.instance_type_ec2
  root_block_device {
    volume_size = var.volume_ec2
    volume_type = var.volumet_instance
  }
  tags = {
    Name = "${var.project_name}-pubsub1"
    Shift = var.shift
  }
}
resource "aws_instance" "pub_ec2_2_2t" {        # EC2 pubsub 2
  ami                    = var.ubuntu_ami # Ubuntu
  key_name               = var.keypair
  subnet_id              = aws_subnet.pub_subnet_2_2t.id
  vpc_security_group_ids = [aws_security_group.pubsubs_sg_2t.id]
  instance_type          = var.instance_type_ec2
  root_block_device {
    volume_size = var.volume_ec2
    volume_type = var.volumet_instance
  }
  tags = {
    Name = "${var.project_name}-pubsub2"
  }
}
resource "aws_db_subnet_group" "rds_sb_subgroup_2t" {     #DB subnet group
  name       = "${var.project_name}-db-subnetgroup"
  subnet_ids = [aws_subnet.priv_subnet_1_2t.id,aws_subnet.priv_subnet_2_2t.id]

  tags = {
    Name = "${var.project_name}-db-subgroup"
  }
}

# Create an RDS database
resource "aws_db_instance" "rds_instance_2t" {          # RDS 
  identifier     = "${var.project_name}-db"
  engine         = var.engine_rds
  engine_version = var.enginev_rds
  instance_class = var.instance_class_rds

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password # Can use the manage_master_user_password via Secrets Manager

  allocated_storage = 20
  storage_type      = var.volumet_instance

  db_subnet_group_name   = aws_db_subnet_group.rds_sb_subgroup_2t.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg_2t.id]
  availability_zone      = var.availability_zones[0]
  skip_final_snapshot = true


  tags = {
    Name = "${var.project_name}-rds-instance"
    Shift = var.shift
  }
}