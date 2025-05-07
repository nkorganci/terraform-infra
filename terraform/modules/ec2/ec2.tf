

variable "public_subnet_id" {
  type        = string
  description = "Public subnet id for instance launch."
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet id for instance launch."
}

variable "ami_id" {
  type        = string
  description = "AMI id for the instance."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "vpc_id" {
  type        = string
  description = "VPC identifier."
}

variable "key_name" {
  type        = string
  description = "Key pair name."
  default     = ""
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP if true; otherwise use the private subnet."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags for the instance and resources."
  default     = {}
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "ec2-sg"
  })
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.assign_public_ip ? var.public_subnet_id : var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name      = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = var.assign_public_ip

  tags = merge(var.tags, {
    Name = "ec2-instance"
  })
}

output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}