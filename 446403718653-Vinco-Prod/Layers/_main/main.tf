terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }



}
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]

}

locals {
  # Add additional tags in the below map
  tags = {
    Environment = var.environment
    CreatedBy   = var.created_by
    Terraform   = true
  }
}

resource "aws_s3_bucket" "state" {
  bucket        = "${var.aws_account_id}-${var.customer_name}-${var.environment}-${var.region}-remote-state-bucket"
  force_destroy = true
  tags          = local.tags

}
resource "aws_s3_bucket_acl" "state_bucket_acl" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}
########## State Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "state_bucket_config" {
  bucket = aws_s3_bucket.state.id
  rule {
    id     = "Expire30"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    expiration {
      days = 30
    }


  }
}
########## State Bucket Server Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_sse" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
######### Block Public Access
resource "aws_s3_bucket_public_access_block" "state_bucket_access" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

