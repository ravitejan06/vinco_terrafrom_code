######## SQL Restore Bucket

output "s3_bucket_arn_aurouz_prod_sql_restore_bucket" {
  value = module.aurouz_prod_sql_restore_bucket.bucket_arn
}

output "s3_bucket_id_aurouz_prod_sql_restore_bucket" {
  value = module.aurouz_prod_sql_restore_bucket.bucket_id
}


####### Public Access Bucket
output "s3_bucket_id_aurouz_prod_public_bucket" {
  value = module.aurouz_prod_public_bucket.bucket_id
}
output "s3_bucket_arn_aurouz_prod_public_bucket" {
  value = module.aurouz_prod_public_bucket.bucket_arn
}
