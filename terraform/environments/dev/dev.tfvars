name        = "ecs-trigger-dev"
environment = "dev"
cidr_block  = "10.0.0.0/16"
aws_region  = "us-east-1"
ami_id = "ami-0f88e80871fd81e91"
bucket_prefix = "s3-bucket"
ecr_repo_name = "ecr-repo"


public_subnet_cidrs = {
  "us-east-1a" = "10.0.1.0/24"
  "us-east-1b" = "10.0.2.0/24"
}

private_subnet_cidrs = {
  "us-east-1a" = "10.0.11.0/24"
  "us-east-1b" = "10.0.12.0/24"
}

tags = {
  Owner      = "platform-team"
  CostCenter = "1234"
}
