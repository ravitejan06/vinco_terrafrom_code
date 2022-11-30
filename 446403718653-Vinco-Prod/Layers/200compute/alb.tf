# ALB Security Group
resource "aws_security_group" "aurouz_prod_alb_sg" {
  description = "ALB Security Group"
  name        = "aurouz-prod-alb-sg"
  vpc_id      = data.terraform_remote_state.remote_state_000base.outputs.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = "aurouz-prod-alb-sg"
    },
  )

}


# ALB Security Group Rule
resource "aws_security_group_rule" "internettoalb443" {
  type              = "ingress"
  description       = "Ingress on Port 443"
  security_group_id = aws_security_group.aurouz_prod_alb_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/13", "104.24.0.0/14", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17"]
}


resource "aws_security_group_rule" "internettoalb80" {
  type              = "ingress"
  description       = "Ingress on Port 80"
  security_group_id = aws_security_group.aurouz_prod_alb_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/13", "104.24.0.0/14", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17"]
}
resource "aws_security_group_rule" "egresstoall" {
  type              = "egress"
  description       = "Egress ALL"
  security_group_id = aws_security_group.aurouz_prod_alb_sg.id
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
