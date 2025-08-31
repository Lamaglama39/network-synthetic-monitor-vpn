terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "global_ip" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  home_global_ip = chomp(data.http.global_ip.body)
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = {
    subnet_1 = {
      cidr_block        = var.private_subnet_1_cidr
      availability_zone = data.aws_availability_zones.available.names[0]
      name_suffix       = "1"
    }
    subnet_2 = {
      cidr_block        = var.private_subnet_2_cidr
      availability_zone = data.aws_availability_zones.available.names[1]
      name_suffix       = "2"
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.project_name}-private-subnet-${each.value.name_suffix}"
  }
}

# Route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Route table associations
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Virtual Private Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-vgw"
  }
}

# Route for VPN Gateway
resource "aws_route" "vpn" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.on_premises_cidr
  gateway_id             = aws_vpn_gateway.main.id
}

# Customer Gateway (represents on-premises side)
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = local.home_global_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-cgw"
  }
}

# VPN Connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "${var.project_name}-vpn"
  }
}

# VPN Connection Route
resource "aws_vpn_connection_route" "on_premises" {
  vpn_connection_id      = aws_vpn_connection.main.id
  destination_cidr_block = var.on_premises_cidr
}

# AWS Network Monitor
resource "aws_networkmonitor_monitor" "main" {
  monitor_name       = "${var.project_name}-network-monitor"
  aggregation_period = 60

  tags = {
    Name = "${var.project_name}-network-monitor"
  }
}

# AWS Network Monitor Probes for PING monitoring
resource "aws_networkmonitor_probe" "ping_probes" {
  for_each = aws_subnet.private

  monitor_name = aws_networkmonitor_monitor.main.monitor_name
  destination  = var.monitoring_target_ip
  protocol     = "ICMP"
  packet_size  = 56
  source_arn   = each.value.arn

  tags = {
    Name = "${var.project_name}-ping-probe-${split("_", each.key)[1]}"
  }
}
