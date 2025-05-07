terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "aws_region"   { type = string }
variable "environment"  { type = string }
variable "name"         { type = string }
variable "cidr_block"   { type = string }
variable "public_subnet_cidrs"  { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
variable "create_internet_gateway" {
  type    = bool
  default = true
}
variable "tags" {
  type    = map(string)
  default = {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  tags = merge(var.tags, {
    Name        = var.name,
    Environment = var.environment
  })
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  count  = var.create_internet_gateway ? 1 : 0
  tags   = local.tags
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each                = var.public_subnet_cidrs
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = "${var.name}-public-${each.key}"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each          = var.private_subnet_cidrs
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(local.tags, {
    Name = "${var.name}-private-${each.key}"
  })
}

# NAT Gateway Allocation
resource "aws_eip" "nat" {
  for_each  = var.public_subnet_cidrs
  vpc       = true
  depends_on = [aws_internet_gateway.this]
  tags      = local.tags
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  for_each      = var.public_subnet_cidrs
  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat[each.key].id
  depends_on    = [aws_internet_gateway.this]
  tags          = local.tags
}

# Public Route Tables
resource "aws_route_table" "public" {
  for_each = var.public_subnet_cidrs
  vpc_id   = aws_vpc.this.id
  tags = merge(local.tags, {
    Name = "${var.name}-rtb-public-${each.key}"
  })
}

# Public Routes
resource "aws_route" "public_internet_access" {
  for_each               = aws_route_table.public
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
  depends_on             = [aws_internet_gateway.this]
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

# Private Route Tables
resource "aws_route_table" "private" {
  for_each = var.private_subnet_cidrs
  vpc_id   = aws_vpc.this.id
  tags = merge(local.tags, {
    Name = "${var.name}-rtb-private-${each.key}"
  })
}

# Private Routes for NAT Gateway access
resource "aws_route" "private_nat_access" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
  depends_on             = [aws_nat_gateway.this]
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_cidrs
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]
  tags              = local.tags
}



# Outputs
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}