output "home_global_ip" {
  value = local.home_global_ip
}

output "vpc_cidr" {  
  value = aws_vpc.main.cidr_block
}

output "vpn_connection_tunnel_1_address" {
  description = "Public IP address of VPN tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "vpn_connection_tunnel_2_address" {
  description = "Public IP address of VPN tunnel 2"
  value       = aws_vpn_connection.main.tunnel2_address
}

output "vpn_connection_tunnel_1_preshared_key" {
  description = "Preshared key for VPN tunnel 1"
  value       = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive   = true
}

output "vpn_connection_tunnel_2_preshared_key" {
  description = "Preshared key for VPN tunnel 2"
  value       = aws_vpn_connection.main.tunnel2_preshared_key
  sensitive   = true
}
