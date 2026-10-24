
# ============================================
# HawkerCare - AWS Network Infrastructure
# Region: ap-southeast-1 (Singapore)
# ============================================

# Get two available AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ============================================
# 1. Virtual Private Cloud
# ============================================

resource "aws_vpc" "hawker_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "HawkerCare-VPC"
  }
}

# ============================================
# 2. Internet Gateway
# ============================================

resource "aws_internet_gateway" "hawker_igw" {
  vpc_id = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-IGW"
  }
}

# ============================================
# 3. Public Subnets - Load Balancer
# ============================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.hawker_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "HawkerCare-Public-${count.index + 1}"
    Tier = "Public"
  }
}

# ============================================
# 4. Private Application Subnets
# OutSystems Windows EC2 Servers
# ============================================

resource "aws_subnet" "app" {
  count = length(var.app_subnet_cidrs)

  vpc_id                  = aws_vpc.hawker_vpc.id
  cidr_block              = var.app_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "HawkerCare-App-${count.index + 1}"
    Tier = "Application"
  }
}

# ============================================
# 5. Private Database Subnets
# Amazon RDS SQL Server
# ============================================

resource "aws_subnet" "database" {
  count = length(var.db_subnet_cidrs)

  vpc_id                  = aws_vpc.hawker_vpc.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "HawkerCare-Database-${count.index + 1}"
    Tier = "Database"
  }
}

# ============================================
# 6. Public Route Table
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-Public-RT"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hawker_igw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================
# 7. NAT Gateways
# One per Availability Zone
# ============================================

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "HawkerCare-NAT-EIP-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_route.public_internet]

  tags = {
    Name = "HawkerCare-NAT-${count.index + 1}"
  }
}

# ============================================
# 8. Private Application Route Tables
# Application servers can access internet
# through their NAT Gateways
# ============================================

resource "aws_route_table" "app" {
  count  = length(var.app_subnet_cidrs)
  vpc_id = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-App-RT-${count.index + 1}"
  }
}

resource "aws_route" "app_internet" {
  count = length(var.app_subnet_cidrs)

  route_table_id         = aws_route_table.app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "app" {
  count = length(var.app_subnet_cidrs)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# ============================================
# 9. Isolated Database Route Table
# No direct internet route for database
# ============================================

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-Database-RT"
  }
}

resource "aws_route_table_association" "database" {
  count = length(var.db_subnet_cidrs)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
