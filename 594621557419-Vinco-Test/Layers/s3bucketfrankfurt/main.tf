######### Frankfurt Region S3 Bucket #############

locals {
  tags = {
    Environment = var.environment
    Terraform   = true
    CreatedBy   = var.created_by

  }
}

module "aurouz_test_deposit_slips" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.3"

  name              = "aurouz-test-deposit-slips" ### change according to environment
  tags              = local.tags
  bucket_acl        = "private"
  environment       = var.environment
  lifecycle_enabled = false
  versioning        = false
  sse_algorithm     = "AES256"
  website           = false
}

###### CORS Configuration for Deposit Slips S3 bucket ###############

resource "aws_s3_bucket_cors_configuration" "cors_deposit_slips" {
  bucket = module.aurouz_test_deposit_slips.bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = []
    #max_age_seconds = 3000
  }
}
