terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # propagate org‑wide tags automatically
  default_tags {
    tags = {
      Project     = "terraform-infra"
      Environment = var.environment
    }
  }
}

module "network" {
  source                = "./modules/vpc"
  aws_region            = var.aws_region
  name                  = var.name
  environment           = var.environment
  cidr_block            = var.cidr_block
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  create_internet_gateway = var.create_internet_gateway
  tags                  = var.tags
}

module "ec2" {
  source            = "./modules/ec2"
  public_subnet_id  = module.network.public_subnet_ids[0]
  private_subnet_id = module.network.private_subnet_ids[0]
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  vpc_id            = module.network.vpc_id
  key_name          = var.key_name
  assign_public_ip  = var.assign_public_ip
  tags              = var.tags
}

module "s3" {
  source        = "./modules/s3"
  bucket_prefix = var.bucket_prefix
  tags          = {
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Environment = var.environment
    Project     = "terraform-infra"
  }
}