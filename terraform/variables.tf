variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnet_cidrs" {
  type = map(string)
}

variable "private_subnet_cidrs" {
  type = map(string)
}

variable "create_internet_gateway" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type = string
}

variable "key_name" {
  type    = string
  default = ""
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "bucket_prefix" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}