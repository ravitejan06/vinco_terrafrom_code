#Account Related
##################

# AWS Account ID
aws_account_id = "594621557419"

# Environment
environment = "test"

# Region
region = "ap-east-1"

# Availabilty Zones
redis_availability_zones = ["ap-east-1c"]
db_availability_zones    = "ap-east-1a"
customer_name            = "vinco"

created_by = "Ravi Teja Nimma"

###RDS Details
rds_password           = "83c2t3Y+QPxa7BE5S+17Dw=="
rds_engine             = "sqlserver-web"
rds_engine_version     = "15.00.4198.2.v1"
rds_instance_class     = "db.t3.medium"
dbname                 = "aurouz-test"
rds_username           = "mssql_user_test"
parameter_group_family = "sqlserver-web-15.0"
redis_instance_type    = "cache.t3.micro"

### RDS Option Group
og_iam_role_name                     = "aurouz_test_og_role"
og_iam_policy_name                   = "aurouz_test_og_policy"
db_option_group_name                 = "aurouz-test-sql-restore-og"
db_option_group_description          = "Option group for Test RDS"
db_option_group_major_engine_version = "15.00"
db_option_name                       = "SQLSERVER_BACKUP_RESTORE"
