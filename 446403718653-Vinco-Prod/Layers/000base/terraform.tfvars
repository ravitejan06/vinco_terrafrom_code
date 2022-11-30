cidr_range = "10.200.0.0/16"

customer_name = "vinco"

vpc_name = "aurouz-prod-vpc"

region = "eu-north-1"

environment = "prod"

aws_account_id = "446403718653" ######Change Later


layer = "000base"

public_cidr_ranges = ["10.200.0.0/25", "10.200.0.128/25", "10.200.1.0/25"]

private_cidr_ranges = ["10.200.2.0/24", "10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/25", "10.200.5.128/25", "10.200.6.0/24"]

private_subnet_names = ["aurouz-prod-snet-pri-1a", "aurouz-prod-snet-pri-1b", "aurouz-prod-snet-pri-1c", "aurouz-prod-snet-db-1a", "aurouz-prod-snet-db-1b", "aurouz-prod-snet-db-1c"]


public_subnet_names = [
  "aurouz-prod-snet-pub-1a",
  "aurouz-prod-snet-pub-1b",
  "aurouz-prod-snet-pub-1c"
]


availability_zones = [
  "eu-north-1a",
  "eu-north-1b",
  "eu-north-1c"
]

sns_topic_name      = "Infra-monitoring-topic"
sns_topic_endpoint1 = "aaron.chung@aurouz.io" ##### To be Defined
name                = "aurouz-prod"
created_by          = "Ravi Teja Nimma"
eks_private_subnettag = {
  "kubernetes.io/role/internal-elb" = "1"
}
eks_public_subnettag = {
  "kubernetes.io/role/elb" = "1"
}
s3_flowlog_retention_period = 35
