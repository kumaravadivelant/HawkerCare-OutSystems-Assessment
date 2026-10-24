
# HawkerCare - Terraform Outputs

output "aws_region" {
  description = "AWS deployment region"
  value       = "ap-southeast-1"
}

output "vpc_id" {
  description = "HawkerCare VPC ID"
  value       = aws_vpc.hawker_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "application_subnet_ids" {
  description = "Application subnet IDs"
  value       = aws_subnet.app[*].id
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "load_balancer_dns" {
  description = "HawkerCare Load Balancer DNS"
  value       = aws_lb.hawker_alb.dns_name
}

output "application_server_ids" {
  description = "OutSystems Windows EC2 IDs"
  value       = aws_instance.outsystems_app[*].id
}

output "sql_server_endpoint" {
  description = "SQL Server database endpoint"
  value       = aws_db_instance.hawker_sqlserver.endpoint
}

output "sql_server_port" {
  description = "SQL Server database port"
  value       = aws_db_instance.hawker_sqlserver.port
}

output "sql_server_secret_arn" {
  description = "RDS-managed master credential secret ARN"
  value       = aws_db_instance.hawker_sqlserver.master_user_secret[0].secret_arn
}
