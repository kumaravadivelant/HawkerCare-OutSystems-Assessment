
# HawkerCare - CloudWatch Monitoring

# 1. Monitor EC2 CPU usage

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count = length(var.app_subnet_cidrs)

  alarm_name          = "HawkerCare-EC2-CPU-${count.index + 1}"
  alarm_description   = "High CPU usage on OutSystems server"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 300
  statistic          = "Average"
  threshold          = 80

  treat_missing_data = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.outsystems_app[count.index].id
  }

  tags = {
    Name = "HawkerCare-EC2-Monitor"
  }
}

# 2. Monitor SQL Server CPU usage

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "HawkerCare-RDS-CPU"
  alarm_description   = "High SQL Server CPU usage"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = 300
  statistic          = "Average"
  threshold          = 80

  treat_missing_data = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.hawker_sqlserver.identifier
  }

  tags = {
    Name = "HawkerCare-RDS-Monitor"
  }
}

# 3. Monitor unhealthy load balancer targets

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "HawkerCare-ALB-Unhealthy"
  alarm_description   = "Unhealthy OutSystems application targets"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "UnHealthyHostCount"
  namespace          = "AWS/ApplicationELB"
  period             = 60
  statistic          = "Maximum"
  threshold          = 0

  treat_missing_data = "missing"

  dimensions = {
    LoadBalancer = aws_lb.hawker_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.hawker_targets.arn_suffix
  }

  tags = {
    Name = "HawkerCare-ALB-Monitor"
  }
}
