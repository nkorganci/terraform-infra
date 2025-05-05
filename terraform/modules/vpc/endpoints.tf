resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt_name, rt in aws_route_table.private : rt.id]
  tags              = local.tags
}