variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "network-synthetic-monitor"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.1.0/24"
}

variable "on_premises_cidr" {
  description = "CIDR block for on-premises network"
  type        = string
}

variable "monitoring_target_ip" {
  description = "IP address of the on-premises resource to monitor via PING"
  type        = string
}
