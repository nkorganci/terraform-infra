variable "role_name" {
  description = "The name of the IAM role."
  type        = string
}


variable "assume_role_policy" {
  description = "The assume role policy JSON for the IAM role."
  type        = string
}

variable "attached_policy_arns" {
  description = "A list of policy ARNs to attach to the IAM role."
  type        = list(string)
  default     = [
    # Read-only access to S3 buckets
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",

    # Full access to DynamoDB tables
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",

    # Permissions to write logs in CloudWatch
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each   = toset(var.attached_policy_arns)
  role       = aws_iam_role.this.name

}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.this.arn
}

