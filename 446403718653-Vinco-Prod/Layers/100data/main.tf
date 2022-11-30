terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 4.39.0"
  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.prod.100data.tfstate"
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
data "aws_region" "current" {

}
data "aws_caller_identity" "current" {
}

locals {
  tags = {
    Environment = var.environment
    Layer       = "100data"
    Terraform   = true
    CreatedBy   = var.created_by

  }
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


############################### RDS Instance Security Groups ###############################

# RDS Security Group
resource "aws_security_group" "aurouz_prod_db_sg" {
  name   = "aurouz-prod-db-sg"
  vpc_id = data.terraform_remote_state.remote_state_000base.outputs.vpc_id

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.remote_state_200compute.outputs.bastion_sg_id]
  }

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.remote_state_200compute.outputs.cluster_primary_security_group_id] ##ADD EKS SG here
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aurouz-prod-db-sg"
  }


}


################### Security Group for Redis ##########################
resource "aws_security_group" "aurouz_prod_cache_sg" {
  name   = "aurouz-prod-cache-sg"
  vpc_id = data.terraform_remote_state.remote_state_000base.outputs.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.remote_state_200compute.outputs.cluster_primary_security_group_id] ##### Inbound From EKS SG

  }
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.remote_state_200compute.outputs.bastion_sg_id] ##### Inbound From Jump

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]


  }


  tags = {
    Name = "aurouz-prod-cache-sg"
  }


}



########## Create RDS Instance  #################
#### IAM Role for RDS Option group
resource "aws_iam_role" "aurouz_prod_og_role" {
  name = var.og_iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })

}
resource "aws_iam_role_policy" "aurouz_prod_og_policy" {
  name = var.og_iam_policy_name
  role = aws_iam_role.aurouz_prod_og_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::aurouz-prod-sql-restore-bucket"
        ]
      },
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::aurouz-prod-sql-restore-bucket/*"
      },
    ]
  })
}

resource "aws_db_instance" "rds_mssql" {
  allocated_storage               = 20
  max_allocated_storage           = 1000
  port                            = 1433
  engine                          = var.rds_engine
  engine_version                  = var.rds_engine_version
  license_model                   = "license-included"
  instance_class                  = var.rds_instance_class
  identifier                      = var.dbname
  multi_az                        = true
  publicly_accessible             = false
  username                        = var.rds_username
  password                        = var.rds_password
  parameter_group_name            = aws_db_parameter_group.mssql_pg.id
  db_subnet_group_name            = aws_db_subnet_group.aurouz_rds_subnet_group.id
  option_group_name               = aws_db_option_group.aurouz_prod_og.id
  vpc_security_group_ids          = [aws_security_group.aurouz_prod_db_sg.id]
  storage_encrypted               = true
  timezone                        = "UTC"
  maintenance_window              = "Sun:03:30-Sun:05:30"
  backup_retention_period         = 35
  backup_window                   = "01:30-03:30"
  auto_minor_version_upgrade      = true
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = ["error", "agent"]
  tags = merge(
    local.tags,
    { Backup = "True" }

  )
}

######## RDS Subnet Group
resource "aws_db_subnet_group" "aurouz_rds_subnet_group" {
  name       = "aurouz-${var.environment}-subnet-group"
  subnet_ids = [data.terraform_remote_state.remote_state_000base.outputs.private_subnets[3], data.terraform_remote_state.remote_state_000base.outputs.private_subnets[4]]
  tags = merge(
    local.tags,
    { Name = "aurouz-${var.environment}-subnet-group" }

  )
}

####### RDS Parameter Group
resource "aws_db_parameter_group" "mssql_pg" {
  name   = "aurouz-pg-${var.environment}"
  family = var.parameter_group_family

}

######### RDS Option Group
resource "aws_db_option_group" "aurouz_prod_og" {
  name                     = var.db_option_group_name
  option_group_description = var.db_option_group_description
  engine_name              = var.rds_engine
  major_engine_version     = var.db_option_group_major_engine_version

  option {
    option_name = var.db_option_name

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.aurouz_prod_og_role.arn
    }
  }

}

################# Create Redis Cluster #########################################


module "elasticache_redis" {
  source                               = "../../../modules/elasticache_redis"
  name                                 = "aurouz-prod-cache-db" ########
  cluster_mode_enabled                 = true
  family                               = "redis7"
  engine_version                       = "7.0"
  instance_type                        = var.redis_instance_type
  cluster_mode_num_node_groups         = 2
  cluster_mode_replicas_per_node_group = 1
  vpc_id                               = data.terraform_remote_state.remote_state_000base.outputs.vpc_id
  subnets                              = [data.terraform_remote_state.remote_state_000base.outputs.private_subnets[4], data.terraform_remote_state.remote_state_000base.outputs.private_subnets[5]]
  create_security_group                = false
  associated_security_group_ids        = [aws_security_group.aurouz_prod_cache_sg.id]
  at_rest_encryption_enabled           = true
  multi_az_enabled                     = true
  maintenance_window                   = "Sun:03:30-Sun:05:30"
  automatic_failover_enabled           = true
  snapshot_window                      = "01:30-03:30"
  snapshot_retention_limit             = 35
  auto_minor_version_upgrade           = true
  notification_topic_arn               = data.terraform_remote_state.remote_state_000base.outputs.sns_topic_arn
  log_delivery_configuration = [{
    destination      = data.terraform_remote_state.remote_state_000base.outputs.redis_cwlog_group_name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
    },
    {
      destination      = data.terraform_remote_state.remote_state_000base.outputs.redis_cwlog_group_name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    }

  ]
  tags = local.tags
}
