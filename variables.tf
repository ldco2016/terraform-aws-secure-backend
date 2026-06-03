variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "my-unique-compliance-state-bucket-2026" # Change this to be unique!
}