terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. The Customer Master Key (KMS CMK) for SSE-KMS Encryption
resource "aws_kms_key" "terraform_key" {
  description             = "KMS Key for encrypting secure medical state data"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Proves I undertand compliance auditing!

  tags = {
    Name = "terraform-state-key"
  }
}

# 2. The Secure S3 Bucket
resource "aws_s3_bucket" "state_bucket" {
  bucket        = var.bucket_name
  force_destroy = true # Allows easy 'terraform destroy' without manual emptying

  tags = {
    Name = "secure-terraform-state"
  }
}

# 3. Apply the SSE-KMS Encryption using our custom key
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_key.arn
      sse_algorithm     = "aws:kms" # Maps directly to my SSE-KMS notes!
    }
  }
}

# 4. Strict Bucket Policy: Enforce In-Transit Encryption (HTTPS Only) 
resource "aws_s3_bucket_policy" "enforce_tls" {
  bucket = aws_s3_bucket.state_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false" # Rejects non-HTTPS traffic
          }
        }
      }
    ]
  })
}

# 5. DynamoDB Table for State Locking (Prevents concurrent apply operations)
resource "aws_dynamodb_table" "state_locks" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST" # Crucial for cost optimization! $0 when idle.
  hash_key     = "LockID"          # This exact attribute name is required by Terraform for state locking

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-lock-table"
  }
}