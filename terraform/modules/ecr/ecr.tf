variable "repository_name" {
  type        = string
  description = "Name of the ECR repository."
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability."
  default     = "MUTABLE"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources."
  default     = {}
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  tags                 = var.tags
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}