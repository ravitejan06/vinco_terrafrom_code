terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }
  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.300dns.tfstate"
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

data "aws_caller_identity" "current" {
}
data "aws_region" "current" {

}

data "terraform_remote_state" "remote_state_000base" {
  backend = "s3"

  config = {
    key     = "terraform.vinco.prod.000base.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }
}


data "terraform_remote_state" "remote_state_100data" {
  backend = "s3"

  config = {
    key     = "terraform.vinco.prod.100data.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }
}

data "terraform_remote_state" "remote_state_200compute" {
  backend = "s3"

  config = {
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    key     = "terraform.vinco.prod.200compute.tfstate"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }
}


#################### Route53 ###############################

locals {
  tags = {
    Environment = var.environment
    Layer       = "300dns"
    Terraform   = true
    CreatedBy   = var.created_by

  }
}

module "private_internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone//?ref=v0.12.0"

  tags   = local.tags
  vpc_id = data.terraform_remote_state.remote_state_000base.outputs.vpc_id
  name   = "aurouz-prod-net.local"
}

resource "aws_route53_record" "rds_zone_record" {

  name    = var.rds_record_name
  records = [data.terraform_remote_state.remote_state_100data.outputs.db_address_record]
  ttl     = "300"
  type    = "CNAME"
  zone_id = module.private_internal_zone.internal_hosted_zone_id
}
resource "aws_route53_record" "redis_zone_record" {

  name    = var.redis_record_name
  records = [data.terraform_remote_state.remote_state_100data.outputs.redis_endpoint_record]
  ttl     = "300"
  type    = "CNAME"
  zone_id = module.private_internal_zone.internal_hosted_zone_id
}


