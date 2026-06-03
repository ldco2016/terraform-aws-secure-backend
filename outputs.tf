output "s3_bucket_arn" {
  description = "The ARN of the secure state bucket"
  value       = aws_s3_bucket.state_bucket.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB locking table"
  value       = aws_dynamodb_table.state_locks.name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key protecting the data"
  value       = aws_kms_key.terraform_key.arn
}
