terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }
  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.test.s3frankfurt.tfstate"
    bucket  = "594621557419-vinco-test-ap-east-1-remote-state-bucket"
    region  = "ap-east-1"
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
