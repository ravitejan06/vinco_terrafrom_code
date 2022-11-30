terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.s3buckets.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }

}

provider "aws" {

  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}


locals {
  tags = {
    Environment = var.environment
    Layer       = "_s3buckets"
    Terraform   = true
    CreatedBy   = var.created_by
  }
}



######### SQL Restore S3 Bucket ####################

module "aurouz_prod_sql_restore_bucket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.3"

  name              = "aurouz-prod-sql-restore-bucket" ### change according to environment
  tags              = local.tags
  bucket_acl        = "private"
  environment       = var.environment
  lifecycle_enabled = false
  versioning        = false
  sse_algorithm     = "AES256"
  website           = false
}

################# S3 Bucket Public Access #################

module "aurouz_prod_public_bucket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.3"

  name              = "aurouz-prod-public-bucket" ### change according to environment
  tags              = local.tags
  bucket_acl        = "public-read"
  environment       = var.environment
  lifecycle_enabled = false
  versioning        = false
  sse_algorithm     = "AES256"
  website           = false
}

