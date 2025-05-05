resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_ec2" {
  count                   = 1
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.public_subnet_id
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]
  user_data               = var.user_data
  tags = {
    Name = "public-ec2-${count.index}"
  }
}

resource "aws_instance" "private_ec2" {
  count                   = 2
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_id
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]
  user_data               = var.user_data
  tags = {
    Name = "private-ec2-${count.index}"
  }
}