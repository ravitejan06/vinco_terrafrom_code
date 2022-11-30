#Account Related
##################

# AWS Account ID
aws_account_id = "446403718653"

# Environment
environment = "prod"

# Region
region = "eu-north-1"

customer_name = "vinco"

created_by = "Ravi Teja Nimma"

###RDS Details
rds_password           = "83c2t3Y+QPxa7BE5S+17Dw=="
rds_engine             = "sqlserver-se"
rds_engine_version     = "15.00.4198.2.v1"
rds_instance_class     = "db.t3.xlarge"
dbname                 = "aurouz-prod"
rds_username           = "mssql_user_prod"
parameter_group_family = "sqlserver-se-15.0"
redis_instance_type    = "cache.t3.micro"

### RDS Option Group
og_iam_role_name                     = "aurouz_prod_og_role"
og_iam_policy_name                   = "aurouz_prod_og_policy"
db_option_group_name                 = "aurouz-prod-sql-restore-og"
db_option_group_description          = "Option group for Prod RDS"
db_option_group_major_engine_version = "15.00"
db_option_name                       = "SQLSERVER_BACKUP_RESTORE"
