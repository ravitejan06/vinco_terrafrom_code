
output "vpn_endpoint_dns" {
  value = aws_ec2_client_vpn_endpoint.client_site_vpn.dns_name

}
output "vpn_endpoint_id" {

  value = aws_ec2_client_vpn_endpoint.client_site_vpn.id
}
