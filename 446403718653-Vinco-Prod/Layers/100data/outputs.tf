
#### RDS SG
output "aurouz_prod_db_sg_id" {
  description = "RDS Security Group ID."
  value       = aws_security_group.aurouz_prod_db_sg.id
}

output "aurouz_prod_db_sg_name" {
  description = "RDS Security Group Name."
  value       = aws_security_group.aurouz_prod_db_sg.name
}

####### RDS details
output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.rds_mssql.arn
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.rds_mssql.id
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds_mssql.endpoint
}

output "db_address_record" {
  value = aws_db_instance.rds_mssql.address

}



##### Redis SG
output "aurouz_prod_cache_sg_id" {
  description = "Redis Cache Security Group ID."
  value       = aws_security_group.aurouz_prod_cache_sg.id
}

output "aurouz_prod_cache_sg_name" {
  description = "Redis Cache Security Group Name."
  value       = aws_security_group.aurouz_prod_cache_sg.name
}
### Redis Cluster Details
output "redis_cluster_id" {
  value       = module.elasticache_redis.id
  description = "Redis cluster ID"
}

output "redis_cluster_arn" {
  value       = module.elasticache_redis.arn
  description = "Elasticache Replication Group ARN"
}

output "redis_endpoint_record" {
  value = module.elasticache_redis.endpoint
}

output "redis_cluster_reader_endpoint_address" {
  value       = module.elasticache_redis.reader_endpoint_address
  description = "Redis non-cluster reader endpoint"
}
output "redis_cluster_enabled" {
  value       = module.elasticache_redis.cluster_enabled
  description = "Indicates if cluster mode is enabled"
}
