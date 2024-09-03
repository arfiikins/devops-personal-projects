resource "aws_security_group" "alb_sg_2t" {             # ALB SG
  name = "${var.project_name}-alb-sg"
  description = "Allow HTTP and HTTPS traffic from everywhere"
  vpc_id = aws_vpc.vpc_2t.id
  ingress {
    description = "allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_2t.cidr_block] #change to 0.0.0.0/0
  }
  ingress {
    description = "allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_2t.cidr_block] #change to 0.0.0.0/0
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all] 
  }
}
resource "aws_security_group" "pubsubs_sg_2t" {             # pubsub SG
  name = "${var.project_name}-pubsubs-sg"
  description = "Allow traffic from ALB"
  vpc_id = aws_vpc.vpc_2t.id
  ingress {
    description = "allow HTTP traffic from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg_2t.id ]
  }
  ingress {
    description = "allow HTTPS traffic from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg_2t.id ]
  }
  egress {
    description = "allow DB access to private subnet 1"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.priv_subnet_1_2t.cidr_block] 
  }
}
resource "aws_security_group" "rds_sg_2t" {             # rds SG
  name = "${var.project_name}-rds-sg"
  description = "Allow traffic from public subnet to RDS"
  vpc_id = aws_vpc.vpc_2t.id
  ingress {
    description = "allow only DB access from pubsubs"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ aws_subnet.pub_subnet_1_2t, aws_subnet.pub_subnet_2_2t ]
  }
  egress {
    description = "allow all" # can change to deny all for restrictions
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all] 
  }
}