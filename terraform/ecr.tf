resource "aws_ecr_repository" "this" {
  name                 = "my-ecr-repo"
  image_tag_mutability = "MUTABLE"
  tags = {
    Environment = var.environment
    Project     = "terraform-infra"
  }
}