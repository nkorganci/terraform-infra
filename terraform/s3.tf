module "s3" {
  source        = "./modules/s3"
  bucket_prefix = "example-bucket"
  tags          = {
    Environment = var.environment
  }
}