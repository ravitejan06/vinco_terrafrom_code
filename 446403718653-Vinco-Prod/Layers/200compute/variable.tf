variable "region" {}

variable "aws_account_id" {}

variable "environment" {}

variable "layer" {}

#Customer Name
variable "customer_name" {
  description = "Cutomer name"
  type        = string
}

variable "bastion_ami" {
  type = string
}


variable "created_by" {
  description = "Name of the person who has created the resource"
  type        = string

}

variable "bastion_keyname" {
  type = string
}
