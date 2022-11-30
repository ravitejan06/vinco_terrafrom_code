terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"

  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.000base.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket" ### change the account no later
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

### Change global tags accordingly
locals {
  tags = {
    Environment = var.environment
    Layer       = "000base"
    Terraform   = true
    CreatedBy   = var.created_by

  }
}

data "terraform_remote_state" "remote_state_s3buckets" {
  backend = "s3"

  config = {
    key     = "terraform.vinco.prod.s3buckets.tfstate"
    bucket  = "446403718653-vinco-prod-eu-north-1-remote-state-bucket"
    region  = "eu-north-1"
    acl     = "private"
    encrypt = "true"
  }
}

module "base_network" {
  source                        = "../../../modules/base_network"
  az_count                      = 3
  cidr_range                    = var.cidr_range
  name                          = var.vpc_name
  public_cidr_ranges            = var.public_cidr_ranges
  private_cidr_ranges           = var.private_cidr_ranges
  private_subnet_names          = var.private_subnet_names
  public_subnet_names           = var.public_subnet_names
  tags                          = local.tags
  public_subnets_per_az         = 1
  private_subnets_per_az        = 2
  build_s3_flow_logs            = true
  build_igw                     = true
  build_nat_gateways            = true
  single_nat                    = true
  logging_bucket_name           = "aurouz-prod-logs-bucket" ######### Change Later ###############
  s3_flowlog_retention          = var.s3_flowlog_retention_period
  logging_bucket_access_control = "private"
  logging_bucket_encryption     = "AES256"
  default_tenancy               = "default"
  enable_dns_hostnames          = true
  enable_dns_support            = true
  environment                   = var.environment
  eks_private_subnettag         = var.eks_private_subnettag
  eks_public_subnettag          = var.eks_public_subnettag

}



##################### VPC S3 Endpoint ##############################

module "vpc_endpoint" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_endpoint?ref=v0.12.5"

  dynamo_db_endpoint_enable = false
  gateway_endpoints         = ["s3"]
  subnets                   = module.base_network.private_subnets
  s3_endpoint_enable        = false
  vpc_id                    = module.base_network.vpc_id
  route_tables = concat(
    module.base_network.private_route_tables,
    module.base_network.public_route_tables,
  )
  tags = merge(local.tags, {
    Name = "${var.name}-s3-endpoint"
  })
}


########################### SNS Topic ###############################################

module "sns_topic" {
  source                = "github.com/rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.12.1"
  name                  = var.sns_topic_name
  create_subscription_1 = true
  endpoint_1            = var.sns_topic_endpoint1
  protocol_1            = "email"
}



############## Cloudwatch Log group for Redis ##############
module "redis_cwlog_logs" {
  source            = "cloudposse/cloudwatch-logs/aws"
  version           = "0.6.5"
  iam_role_enabled  = true
  namespace         = "aurouz"
  name              = "redislogs"
  retention_in_days = 30
}

############## Cloudwatch Log group for Connection Logs ##############
module "vpn_connection_logs" {
  source            = "cloudposse/cloudwatch-logs/aws"
  version           = "0.6.5"
  iam_role_enabled  = true
  namespace         = "aurouz"
  name              = "vpn_connection_logs"
  retention_in_days = 30
}

