terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }
  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.s3frankfurt.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }
}
provider "aws" {

  region              = "eu-central-1"
  allowed_account_ids = [var.aws_account_id]

}

data "aws_caller_identity" "current" {
}
