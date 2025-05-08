output "vpc_id" {
  value = module.network.vpc_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.this.repository_url
}