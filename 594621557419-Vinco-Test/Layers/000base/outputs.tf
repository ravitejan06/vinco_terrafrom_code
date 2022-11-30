output "vpc_id" {
  description = "VPC ID."
  value       = module.base_network.vpc_id
}

output "vpc_name" {
  description = "VPC ID."
  value       = module.base_network.vpc_id
}

output "vpc_cidr" {
  description = "vpc_cidr"
  value       = var.cidr_range
}

output "customer_name" {
  description = "customer_name."
  value       = var.customer_name
}


output "private_subnets" {
  description = "private_subnets"
  value       = module.base_network.private_subnets
}


output "public_subnets" {
  description = "private_subnets"
  value       = module.base_network.public_subnets
}


output "public_cidr_ranges" {
  description = "public_cidr_ranges"
  value       = var.public_cidr_ranges
}

output "private_cidr_ranges" {
  description = "private_cidr_ranges"
  value       = var.private_cidr_ranges
}
###### SNS
output "sns_topic_arn" {
  description = "Sns topic Arn"
  value       = module.sns_topic.topic_arn
}


output "sns_topic_id" {
  description = "SNS topic id."
  value       = module.sns_topic.topic_id
}

######### Redis Logs
output "redis_cwlog_group_arn" {
  value       = module.redis_cwlog_logs.log_group_arn
  description = "ARN of the log group"
}

output "redis_cwlog_group_name" {
  value       = module.redis_cwlog_logs.log_group_name
  description = "Name of log group"
}

output "redis_cwlog_arn" {
  value       = module.redis_cwlog_logs.role_arn
  description = "ARN of role to assume"
}

output "redis_cwlog_role_name" {
  value       = module.redis_cwlog_logs.role_name
  description = "Name of role to assume"
}

###VPC Endpoint
output "s3_vpc_endpoint_id" {
  value = module.vpc_endpoint.s3_vpc_endpoint_id

}
