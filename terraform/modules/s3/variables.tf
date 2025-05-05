variable "bucket_prefix" {
  type    = string
  default = "my-bucket"
}
variable "tags" {
  type    = map(string)
  default = {}
}