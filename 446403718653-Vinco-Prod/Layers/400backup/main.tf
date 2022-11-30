terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.400backup.tfstate"
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


module "backup" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-backup//modules/backup/?ref=v0.12.0"

  #create_iam_role = false
  iam_role_arn = data.terraform_remote_state.remote_state_200compute.outputs.aws_backup_role_arn
  plan_name    = var.plan_name
  environment  = var.environment

  resources = [
    "arn:aws:ec2:eu-north-1:446403718653:instance/*", "arn:aws:rds:eu-north-1:446403718653:db:*"
  ]

  rule_name      = var.rule_name
  selection_name = var.selection_name

  selection_tag = [
    {
      type  = "STRINGEQUALS"
      key   = "Backup"
      value = "True"
    },
  ]
  vault_name        = var.vault_name
  schedule          = "cron(30 1 * * ? *)"
  start_window      = 60
  completion_window = 120
  lifecycle_enable  = true
  lifecycle_bu = {
    delete_after = 7
  }
}
