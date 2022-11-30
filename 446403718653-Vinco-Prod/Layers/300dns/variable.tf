variable "rds_record_name" {
  type = string

}
variable "redis_record_name" {
  type = string

}

variable "environment" {

}
variable "created_by" {
  description = "Name of the person who has created the resource"
  type        = string

}
variable "aws_account_id" {}
variable "region" {}
