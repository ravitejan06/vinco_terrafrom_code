

######Bastion SG
output "bastion_sg_id" {
  value = aws_security_group.aurouz_test_jump_sg.id

}

output "bastion_sg_name" {
  value = aws_security_group.aurouz_test_jump_sg.name

}

####### ALB SG
output "aurouz_test_alb_sg_id" {
  value = aws_security_group.aurouz_test_alb_sg.id

}
output "aurouz_test_alb_sg_name" {
  value = aws_security_group.aurouz_test_alb_sg.name

}

######### EKS SG
# output "aurouz_test_eks_sg_id" {
#   value = aws_security_group.aurouz_test_eks_sg.id

# }
# output "aurouz_test_eks_sg_name" {
#   value = aws_security_group.aurouz_test_eks_sg.name

# }

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(aws_eks_cluster.aurouz_test_eks_cluster.vpc_config[0].cluster_security_group_id, "")
}

######### EKS Cluster and Node Group
output "eks_cluster_name" {
  value = aws_eks_cluster.aurouz_test_eks_cluster.name

}

output "eks_cluster_id" {
  value = aws_eks_cluster.aurouz_test_eks_cluster.id

}

output "eks_node_group_arn" {
  value = aws_eks_node_group.aurouz_test_eks_workernodes_group.arn

}

output "eks_node_group_id" {
  value = aws_eks_node_group.aurouz_test_eks_workernodes_group.id

}

##### IAM Backup Role
output "aws_backup_role_arn" {
  value = aws_iam_role.aws_backup_role.arn
}
output "aws_backup_role_name" {
  value = aws_iam_role.aws_backup_role.name
}
output "aws_backup_role_id" {
  value = aws_iam_role.aws_backup_role.id

}
