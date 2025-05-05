variable "public_subnet_id" {
  type = string
}
variable "private_subnet_id" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "vpc_id" {
  type = string
}
variable "user_data" {
  type    = string
  default = "#!/bin/bash\nyum update -y\nyum install -y httpd\nsystemctl enable httpd\nsystemctl start httpd\necho \"Hello from Amazon Linux!\" > /var/www/html/index.html\n"
}