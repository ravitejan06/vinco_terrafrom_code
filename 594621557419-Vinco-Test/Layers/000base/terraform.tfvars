cidr_range = "10.100.0.0/16"

customer_name = "vinco"

vpc_name = "aurouz-test-vpc"

region = "ap-east-1"

environment = "test"

aws_account_id = "594621557419"


layer = "000base"

public_cidr_ranges = ["10.100.0.0/25", "10.100.0.128/25", "10.100.1.0/25"]

private_cidr_ranges = ["10.100.2.0/24", "10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/25", "10.100.5.128/25", "10.100.6.0/24"]

private_subnet_names = ["aurouz-test-snet-pri-1a", "aurouz-test-snet-pri-1b", "aurouz-test-snet-pri-1c", "aurouz-test-snet-db-1a", "aurouz-test-snet-db-1b", "aurouz-test-snet-db-1c"]


public_subnet_names = [
  "aurouz-test-snet-pub-1a",
  "aurouz-test-snet-pub-1b",
  "aurouz-test-snet-pub-1c"
]


availability_zones = [
  "ap-east-1a",
  "ap-east-1b",
  "ap-east-1c"
]

sns_topic_name      = "Infra-monitoring-topic"
sns_topic_endpoint1 = "aaron.chung@aurouz.io"
name                = "aurouz-test"
created_by          = "Ravi Teja Nimma"

eks_private_subnettag = {
  "kubernetes.io/role/internal-elb" = "1"
}
eks_public_subnettag = {
  "kubernetes.io/role/elb" = "1"
}
s3_flowlog_retention_period = 35
