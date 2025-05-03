module "network" {
  source = "./modules/vpc"

  # simply forward the root variables
  name                    = var.name
  environment             = var.environment
  cidr_block              = var.cidr_block
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  create_internet_gateway = var.create_internet_gateway
  tags                    = var.tags
}

