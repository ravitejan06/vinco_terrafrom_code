terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = ">= 3.0"
  }

  backend "s3" {
    # this key must be unique for each layer!
    key     = "terraform.vinco.test.200compute.tfstate"
    bucket  = "594621557419-vinco-test-ap-east-1-remote-state-bucket"
    region  = "ap-east-1"
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


locals {
  tags = {
    Environment = var.environment
    Layer       = "200compute"
    Terraform   = true
    CreatedBy   = var.created_by
  }
}

data "terraform_remote_state" "remote_state_000base" {
  backend = "s3"

  config = {
    key     = "terraform.vinco.test.000base.tfstate"
    bucket  = "594621557419-vinco-test-ap-east-1-remote-state-bucket"
    region  = "ap-east-1"
    acl     = "private"
    encrypt = "true"
  }
}
data "terraform_remote_state" "remote_state_100data" {
  backend = "s3"

  config = {
    key     = "terraform.vinco.test.100data.tfstate"
    bucket  = "594621557419-vinco-test-ap-east-1-remote-state-bucket"
    region  = "ap-east-1"
    acl     = "private"
    encrypt = "true"
  }
}



############################### Bastion EC2 Resource ###############################

##### Bastion Security Group #########
resource "aws_security_group" "aurouz_test_jump_sg" {
  name        = "aurouz-test-jump-sg"
  description = "Allow inbound traffic to the Jump server"
  vpc_id      = data.terraform_remote_state.remote_state_000base.outputs.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ############# Add VINCO On-Prem CIDR Later
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_eks_cluster.aurouz_test_eks_cluster.vpc_config[0].cluster_security_group_id, data.terraform_remote_state.remote_state_100data.outputs.aurouz_test_cache_sg_id, data.terraform_remote_state.remote_state_100data.outputs.aurouz_test_db_sg_id]

  }
  tags = {
    Name = "aurouz-test-jump-sg"
  }
}

######### Bastion AWS KEY PAIR ##########

data "aws_key_pair" "bastion_keypair" {
  key_name = "aurouz_test_bastionkey"

}


########## Bastion EC2 Resource Creation ############

module "aurouz_test_windows_bastion" {
  source = "../../../modules/windows_bastion"

  ec2_os                     = "windows2022"
  image_id                   = var.bastion_ami
  subnets                    = [data.terraform_remote_state.remote_state_000base.outputs.public_subnets[0]]
  name                       = "aurouz-test-windows-bastion"
  key_pair                   = data.aws_key_pair.bastion_keypair.key_name
  security_groups            = [aws_security_group.aurouz_test_jump_sg.id]
  instance_type              = "t3.micro"
  primary_ebs_volume_size    = 30
  primary_ebs_volume_iops    = 3000
  primary_ebs_volume_type    = "gp3"
  encrypt_primary_ebs_volume = true
  notification_topic         = data.terraform_remote_state.remote_state_000base.outputs.sns_topic_arn
  environment                = var.environment
  tags                       = local.tags
}







######################## EKS Cluster######################################

########### EKS SECURITY GROUP

#### EKS Jump Ingress Security Group Rule
resource "aws_security_group_rule" "test_eks_sg_ingress_rule" {
  type                     = "ingress"
  security_group_id        = aws_eks_cluster.aurouz_test_eks_cluster.vpc_config[0].cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aurouz_test_jump_sg.id
  #depends_on               = [aws_eks_cluster.aurouz_test_eks_cluster]

}


#### ALB Ingress Security Group Rule
resource "aws_security_group_rule" "test_eks_sg_alb_ingress" {
  type                     = "ingress"
  security_group_id        = aws_eks_cluster.aurouz_test_eks_cluster.vpc_config[0].cluster_security_group_id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.aurouz_test_alb_sg.id
  #depends_on               = [aws_eks_cluster.aurouz_test_eks_cluster]
}


######## EKS IAM ROLE
resource "aws_iam_role" "aurouz_test_eks_cluster_role" {
  name = "Aurouz-test-EKS-Cluster-IAMRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aurouz_test_eks_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aurouz_test_eks_cluster_role.name
}

resource "aws_eks_cluster" "aurouz_test_eks_cluster" {
  name     = "Aurouz-test-EKS"
  role_arn = aws_iam_role.aurouz_test_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [data.terraform_remote_state.remote_state_000base.outputs.public_subnets[0], data.terraform_remote_state.remote_state_000base.outputs.public_subnets[1], data.terraform_remote_state.remote_state_000base.outputs.public_subnets[2]]
    #security_group_ids      = [aws_eks_cluster.aurouz_test_eks_cluster.vpc_config[0].cluster_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  depends_on = [
    aws_iam_role_policy_attachment.aurouz_test_eks_cluster_role_policy_attachment, aws_cloudwatch_log_group.aurouz_test_cluster_log_group
  ]
  tags                      = local.tags
  version                   = "1.24"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

resource "aws_cloudwatch_log_group" "aurouz_test_cluster_log_group" {
  name              = "/aws/eks/Aurouz-test-EKS/cluster"
  retention_in_days = 7
}

##### EKS Cluster Add-ons
resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name = aws_eks_cluster.aurouz_test_eks_cluster.name
  addon_name   = "vpc-cni"
}
resource "aws_eks_addon" "coredns_addon" {
  cluster_name = aws_eks_cluster.aurouz_test_eks_cluster.name
  addon_name   = "coredns"
}
resource "aws_eks_addon" "kube_proxy_addon" {
  cluster_name = aws_eks_cluster.aurouz_test_eks_cluster.name
  addon_name   = "kube-proxy"
}
resource "aws_eks_addon" "ebs_csidriver_addon" {
  cluster_name = aws_eks_cluster.aurouz_test_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
}

##################### EKS Cluster Node Group ############################

resource "aws_iam_role" "aurouz_test_eks_worker_role" {
  name = "Aurouz-test-Eks-Workernodes-Role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "auroz_test_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aurouz_test_eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "auroz_test_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aurouz_test_eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "auroz_test_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aurouz_test_eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "auroz_test_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.aurouz_test_eks_worker_role.name
}

resource "aws_eks_node_group" "aurouz_test_eks_workernodes_group" {
  cluster_name    = aws_eks_cluster.aurouz_test_eks_cluster.name
  node_role_arn   = aws_iam_role.aurouz_test_eks_worker_role.arn
  node_group_name = "Aurouz-test-WorkerNode-Group"
  scaling_config {
    min_size     = 3
    desired_size = 3
    max_size     = 3
  }
  update_config {
    max_unavailable = 1
  }
  ami_type       = "AL2_x86_64"
  instance_types = ["m5.xlarge"] #### Change accordingly
  disk_size      = 25            #### Change accordingly
  capacity_type  = "ON_DEMAND"
  subnet_ids     = [data.terraform_remote_state.remote_state_000base.outputs.public_subnets[0], data.terraform_remote_state.remote_state_000base.outputs.public_subnets[1], data.terraform_remote_state.remote_state_000base.outputs.public_subnets[2]]
  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }

  depends_on = [
    aws_iam_role_policy_attachment.auroz_test_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.auroz_test_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.auroz_test_AmazonEC2ContainerRegistryReadOnly
  ]
}
