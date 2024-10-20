provider "aws" {
  region = "us-west-1" 
}


resource "aws_security_group" "ec2_ssh_awscli" {
  name_prefix = "ec2-ssh-awscli-sg"
  description = "Security group for SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["my-ip"]  # input my ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # allow all egress
  }

  tags = {
    Name = "ec2-ssh-awscli-sg"
  }
}


resource "aws_instance" "ubuntu_ec2" {
  ami           = "ami-0d53d72369335a9d6"  # Ubuntu 20.04 LTS AMI in us-west-1
  instance_type = "t2.small"
  key_name      = "mykp"

  vpc_security_group_ids = [aws_security_group.ec2_ssh_awscli.id]

  # User data to install AWS CLI
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y unzip
              sudo apt-get install -y awscli
              EOF

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "Ubuntu-EC2-with-AWS-CLI"
  }
}

# Output the instance's public IP
output "ec2_public_ip" {
  value = aws_instance.ubuntu_ec2.public_ip
  description = "Public IP of the Ubuntu EC2 instance"
}
