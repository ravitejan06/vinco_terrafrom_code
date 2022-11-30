variable "environment" {
  description = "name of environment"
  type        = string
}

variable "region" {
  description = "The AWS region the state should reside in."
  type        = string
}
variable "aws_account_id" {
  description = "The account ID you are building into"
  type        = string
}
variable "created_by" {
  description = "Name of the person who has created the resource"
  type        = string

}


