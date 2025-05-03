variable "aws_region"   { type = string }
variable "environment"  { type = string }

# pass‑throughs that the module needs -----------------------------
variable "name"                  { type = string }
variable "cidr_block"            { type = string }
variable "public_subnet_cidrs"   { type = map(string) }
variable "private_subnet_cidrs"  { type = map(string) }
variable "create_internet_gateway" {
  type    = bool
  default = true
}
variable "tags"                  {
  type = map(string)
  default = {}
}
