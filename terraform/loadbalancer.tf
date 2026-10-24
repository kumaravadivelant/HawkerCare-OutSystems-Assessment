
# HawkerCare - Application Load Balancer

resource "aws_lb" "hawker_alb" {
  name               = "hawker-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "HawkerCare-ALB"
  }
}

# Target group for OutSystems application servers

resource "aws_lb_target_group" "hawker_targets" {
  name        = "hawker-app-targets"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.hawker_vpc.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "HawkerCare-TargetGroup"
  }
}

# Register both Windows EC2 instances

resource "aws_lb_target_group_attachment" "app_servers" {
  count = length(var.app_subnet_cidrs)

  target_group_arn = aws_lb_target_group.hawker_targets.arn
  target_id        = aws_instance.outsystems_app[count.index].id
  port             = 80
}

# HTTP listener - demonstration only

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.hawker_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hawker_targets.arn
  }
}
