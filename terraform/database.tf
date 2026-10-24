
# HawkerCare - Amazon RDS SQL Server

# Private database subnet group

resource "aws_db_subnet_group" "hawker_db_subnets" {
  name = "hawkercare-db-subnets"

  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "HawkerCare-DB-Subnets"
  }
}

# SQL Server Standard Edition
# Demonstration environment only

resource "aws_db_instance" "hawker_sqlserver" {
  identifier = "hawkercare-sqlserver"

  engine         = "sqlserver-se"
  instance_class = "db.m5.large"

  allocated_storage = 100
  storage_type      = "gp2"
  storage_encrypted = true

  username                    = "hawkeradmin"
  manage_master_user_password = true

  port = 1433

  db_subnet_group_name = aws_db_subnet_group.hawker_db_subnets.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  # Single AZ for demonstration
  multi_az = false

  # Automated backup retention
  backup_retention_period = 7
  backup_window           = "18:00-19:00"

  # Maintenance window
  maintenance_window = "Sun:20:00-Sun:21:00"

  # Monitoring
  enabled_cloudwatch_logs_exports = [
    "error",
    "agent"
  ]

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  # Demo only - production should protect data
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "HawkerCare-SQLServer"
    Tier = "Database"
  }
}
