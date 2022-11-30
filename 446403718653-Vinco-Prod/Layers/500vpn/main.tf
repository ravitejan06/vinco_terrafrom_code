terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.500vpn.tfstate"
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




######################### Client-Site VPN ##################################################
locals {
  tags = {
    Environment = var.environment
    Layer       = "500vpn"
    Terraform   = true
    CreatedBy   = var.created_by

  }
}


resource "aws_ec2_client_vpn_endpoint" "client_site_vpn" {
  description            = "Client-Site-VPN"
  server_certificate_arn = "arn:aws:acm:eu-north-1:446403718653:certificate/9dde6294-f843-40a8-b09e-3632ea9c6684"
  client_cidr_block      = var.client_cidr
  security_group_ids     = [aws_security_group.client_vpn_security_group.id]
  vpc_id                 = data.terraform_remote_state.remote_state_000base.outputs.vpc_id
  tags = merge(
    local.tags,
    { Name = "Client-Site-Vpn" }
  )

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:eu-north-1:446403718653:certificate/80d869e7-9244-4110-9ce2-7ba79b06c256"
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = data.terraform_remote_state.remote_state_000base.outputs.vpn_connection_logs_group_name
  }
}

### Private
resource "aws_ec2_client_vpn_network_association" "private" {
  count = 3

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_site_vpn.id
  subnet_id              = element(data.terraform_remote_state.remote_state_000base.outputs.private_subnets, count.index)
}

#### Authorization Rule
resource "aws_ec2_client_vpn_authorization_rule" "vpc_access" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_site_vpn.id
  target_network_cidr    = data.terraform_remote_state.remote_state_000base.outputs.vpc_cidr
  authorize_all_groups   = true
}
resource "aws_ec2_client_vpn_authorization_rule" "Internet_access" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_site_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}


resource "aws_ec2_client_vpn_route" "private_sub_internet" {
  count = 3

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_site_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = element(data.terraform_remote_state.remote_state_000base.outputs.private_subnets, count.index)
}
###### Security Group
resource "aws_security_group" "client_vpn_security_group" {
  description = "Client VPN Security Group"
  vpc_id      = data.terraform_remote_state.remote_state_000base.outputs.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = merge(
    local.tags,
    {
      "Name" = "ClientVpnSecurityGroup"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}


