variable "aws_account_id" {
  description = "The account ID you are building into."
  type        = string
}

variable "environment" {
  description = "The name of the environment, e.g. Production, Staging, etc."
  type        = string
}

variable "layer" {
  description = "The Terraform layer resource was created at."
  type        = string
}

variable "region" {
  description = "The AWS region the state should reside in."
  type        = string
}


variable "cidr_range" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "private_cidr_ranges" {
  description = "An array of CIDR ranges to use for private subnets."
  type        = list(string)
}

variable "private_subnet_names" {
  description = "An array of Names for CIDR ranges to use for private subnets."
  type        = list(string)
}

variable "public_cidr_ranges" {
  description = "An array of CIDR ranges to use for public subnets."
  type        = list(string)
}

variable "public_subnet_names" {
  description = "An array of Names for CIDR ranges to use for public subnets."
  type        = list(string)
}

variable "vpc_name" {
  description = "VPC Name."
  type        = string
}

####Customer Name
variable "customer_name" {
  description = "Customer Name."
  type        = string
}


variable "availability_zones" {
  description = "availability_zones."
  type        = list(string)
}

variable "sns_topic_name" {
  description = "Name of the SNS Topic"
  type        = string
}

variable "sns_topic_endpoint1" {
  description = "value of Endpoint1"
  type        = string
}

variable "name" {
  description = "Name prefix for the VPC and related resources like IGW, NAT etc"
  type        = string
}

variable "created_by" {
  description = "Name of the person who has created the resource"
  type        = string

}
variable "eks_public_subnettag" {
  type = map(string)

}
variable "eks_private_subnettag" {
  type = map(string)
}
variable "s3_flowlog_retention_period" {
  type = number
}


