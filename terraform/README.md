
# HawkerCare - AWS Infrastructure as Code

## Overview

This project provides Terraform infrastructure definitions
for a proposed OutSystems 11 deployment on AWS.

The HawkerCare application currently runs in an OutSystems
Personal Environment. This Terraform project is a separate
AWS infrastructure reference design.

## AWS Region

Singapore: ap-southeast-1

## Architecture

Internet Users
      |
Application Load Balancer
      |
+---------------------------+
| Private Application Tier  |
| Windows EC2 - Server 1    |
| Windows EC2 - Server 2    |
+---------------------------+
      |
Amazon RDS SQL Server
(Private Database Subnets)

## Infrastructure Components

- VPC with public and private subnets
- Two Availability Zones
- Internet Gateway
- NAT Gateways
- Application Load Balancer
- Windows Server 2022 EC2 instances
- Amazon RDS SQL Server Standard Edition
- Security Groups
- IAM role and EC2 instance profile
- AWS Systems Manager permissions
- Amazon CloudWatch monitoring
- RDS automated backups
- Encrypted EC2 and RDS storage

## Security Design

- Application servers have no public IP addresses
- Database is not publicly accessible
- SQL Server access is restricted to application servers
- No public RDP access
- EC2 instances require IMDSv2
- Database master credentials are managed by AWS Secrets Manager

## Deployment Model

This is an infrastructure definition, not a completed
OutSystems installation.

Additional deployment activities include:

1. Install and configure IIS and prerequisites.
2. Install the compatible OutSystems Platform Server.
3. Configure the Deployment Controller and platform services.
4. Configure SQL Server platform databases.
5. Install and configure a separate LifeTime environment.
6. Configure Development and Quality environments.
7. Configure licensing, HTTPS and certificates.
8. Set up production health checks and monitoring notifications.
9. Validate sizing, availability, backups and recovery.

## Terraform Validation

Run:

terraform init -backend=false
terraform fmt -check
terraform validate

## Deployment Safety

Do not run terraform apply without approved AWS credentials,
a reviewed infrastructure plan and budget authorization.

This is an assignment reference design and has not been
deployed to AWS.

## HawkerCare Application Features

- Data retrieval from data.gov.sg
- Search by hawker centre name and location
- Owner filtering
- Sorting
- Pagination
- Loading and API error handling

## Limitations

- The current infrastructure represents one application tier.
- LifeTime and other environments require additional resources.
- HTTPS and application installation are not automated here.
- No live AWS deployment or end-to-end deployment test is claimed.
