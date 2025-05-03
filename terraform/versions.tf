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
