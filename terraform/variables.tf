
# HawkerCare AWS Network Variables

variable "vpc_cidr" {
  description = "IP address range for HawkerCare VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnets for AWS Load Balancer"
  type        = list(string)

  default = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}

variable "app_subnet_cidrs" {
  description = "Private subnets for OutSystems servers"
  type        = list(string)

  default = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

variable "db_subnet_cidrs" {
  description = "Private subnets for SQL Server database"
  type        = list(string)

  default = [
    "10.20.21.0/24",
    "10.20.22.0/24"
  ]
}
