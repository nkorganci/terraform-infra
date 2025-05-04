locals {
    tags = merge(var.tags, {
      Name        = var.name
      Environment = var.environment
    })
  }

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
    tags = merge(local.tags, {
      Name = "${var.name}-public-${each.key}"
    })
  }

  resource "aws_subnet" "private" {
    for_each                = var.private_subnet_cidrs
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value
    availability_zone       = each.key
    map_public_ip_on_launch = false
    tags = merge(local.tags, {
      Name = "${var.name}-private-${each.key}"
    })
  }

  resource "aws_eip" "nat" {
    for_each = var.public_subnet_cidrs
    vpc      = true
    depends_on = [
      aws_internet_gateway.this
    ]
    tags = local.tags
  }

  resource "aws_nat_gateway" "this" {
    for_each      = var.public_subnet_cidrs
    subnet_id     = aws_subnet.public[each.key].id
    allocation_id = aws_eip.nat[each.key].id
    depends_on    = [aws_internet_gateway.this]
    tags          = local.tags
  }

  resource "aws_route_table" "public" {
    for_each = var.public_subnet_cidrs
    vpc_id   = aws_vpc.this.id
    tags = merge(local.tags, {
      Name = "${var.name}-rtb-public-${each.key}"
    })
  }

  resource "aws_route" "public_internet_access" {
    for_each                = aws_route_table.public
    route_table_id          = each.value.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
    depends_on              = [aws_internet_gateway.this]
  }

  resource "aws_route_table_association" "public" {
    for_each       = var.public_subnet_cidrs
    subnet_id      = aws_subnet.public[each.key].id
    route_table_id = aws_route_table.public[each.key].id
  }

  resource "aws_route_table" "private" {
    for_each = var.private_subnet_cidrs
    vpc_id   = aws_vpc.this.id
    tags = merge(local.tags, {
      Name = "${var.name}-rtb-private-${each.key}"
    })
  }

resource "aws_route" "private_nat_access" {
  for_each                = aws_route_table.private
  route_table_id          = each.value.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.this[each.key].id
  depends_on              = [aws_nat_gateway.this]
}

  resource "aws_route_table_association" "private" {
    for_each       = var.private_subnet_cidrs
    subnet_id      = aws_subnet.private[each.key].id
    route_table_id = aws_route_table.private[each.key].id
  }