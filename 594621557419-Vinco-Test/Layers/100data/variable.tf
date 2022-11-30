##################
# Account Related
##################

# AWS Account ID
variable "aws_account_id" {
  description = "The account ID you are building into."
  type        = string
}



# Environment where the deployment is to be done
variable "environment" {
  description = "The name of the environment, e.g. production, Staging, etc."
  type        = string
}

# Change to particular region
variable "region" {
  description = "The AWS region the state should reside in."
  type        = string
}

#Customer Name
variable "customer_name" {
  description = "Cutomer name"
  type        = string
}

variable "created_by" {
  description = "Name of the person who has created the resource"
  type        = string

}

variable "rds_password" {
  description = "Password used to connect to RDS database"
  type        = string

}
variable "rds_engine" {
  description = "Engine Type of RDS"
  type        = string

}
variable "rds_engine_version" {
  description = "Engine version of RDS"
  type        = string

}
variable "rds_instance_class" {
  description = "Type of DB Instance"
  type        = string

}
variable "rds_username" {
  description = "Username of RDS"
  type        = string

}
variable "dbname" {
  description = "Name of the database once DB instance is created"
  type        = string

}

variable "parameter_group_family" {
  type = string
}

variable "redis_availability_zones" {
  type = list(string)

}
variable "redis_instance_type" {
  type = string

}
variable "db_availability_zones" {
  type = string

}

### RDS Option Group
variable "db_option_group_name" {
  type = string

}
variable "db_option_group_description" {
  type = string
}
variable "db_option_group_major_engine_version" {
  type = string
}
variable "db_option_name" {
  type = string
}
variable "og_iam_role_name" {
  type = string
}
variable "og_iam_policy_name" {
  type = string
}
