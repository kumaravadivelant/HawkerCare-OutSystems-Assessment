
# ============================================
# HawkerCare - AWS Security Groups
# ============================================

# 1. Application Load Balancer Security Group

resource "aws_security_group" "alb" {
  name_prefix = "hawkercare-alb-"
  description = "Security group for public load balancer"
  vpc_id      = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-ALB-SG"
  }
}

# Allow HTTP traffic from the internet
# Demo configuration only - production requires HTTPS

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Allow load balancer traffic to application servers

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow traffic to OutSystems servers"

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# ============================================
# 2. OutSystems Application Server
# ============================================

resource "aws_security_group" "app" {
  name_prefix = "haw kercare-app-"
  description = "Security group for OutSystems application servers"
  vpc_id      = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-App-SG"
  }
}

# Only Load Balancer can access application HTTP

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP from ALB"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Allow HTTPS outbound for API calls and updates

resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTPS"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Allow HTTP outbound for dependencies if required

resource "aws_vpc_security_group_egress_rule" "app_http_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTP"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# ============================================
# 3. SQL Server Database
# ============================================

resource "aws_security_group" "database" {
  name_prefix = "haw kercare-db-"
  description = "Security group for RDS SQL Server"
  vpc_id      = aws_vpc.hawker_vpc.id

  tags = {
    Name = "HawkerCare-Database-SG"
  }
}

# Only OutSystems servers can connect to SQL Server

resource "aws_vpc_security_group_ingress_rule" "database_sql" {
  security_group_id = aws_security_group.database.id
  description       = "Allow SQL Server from application"

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 1433
  to_port                      = 1433
  ip_protocol                  = "tcp"
}

# Allow application servers to access SQL Server

resource "aws_vpc_security_group_egress_rule" "app_to_database" {
  security_group_id = aws_security_group.app.id
  description       = "Allow database connectivity"

  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 1433
  to_port                      = 1433
  ip_protocol                  = "tcp"
}
