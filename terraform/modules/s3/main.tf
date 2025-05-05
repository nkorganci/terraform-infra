resource "random_id" "bucket_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3_public" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Allow"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_public.json
}