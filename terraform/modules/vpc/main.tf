resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  count  = var.create_internet_gateway ? 1 : 0
  tags   = local.tags
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnet_cidrs
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${var.name}-public-${each.key}" })
}

# … NAT GWs, private subnets, route tables (unchanged) …
locals {
  tags = merge(var.tags, {
    Name        = var.name
    Environment = var.environment
  })
}