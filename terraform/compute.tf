
# ============================================
# HawkerCare - Windows EC2 Application Servers
# ============================================

# 1. Get latest Windows Server 2022 AMI

data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# ============================================
# 2. IAM Role for EC2 Systems Manager
# ============================================

resource "aws_iam_role" "ec2_ssm" {
  name = "HawkerCare-EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "HawkerCare-EC2-SSM-Role"
  }
}

# 3. Attach permissions for Systems Manager

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================
# 4. EC2 Instance Profile
# ============================================

resource "aws_iam_instance_profile" "app_profile" {
  name = "HawkerCare-App-InstanceProfile"
  role = aws_iam_role.ec2_ssm.name
}

# ============================================
# 5. Windows EC2 Application Servers
# ============================================

resource "aws_instance" "outsystems_app" {
  count = length(var.app_subnet_cidrs)

  ami           = data.aws_ssm_parameter.windows_ami.value
  instance_type = "m5.large"

  subnet_id = aws_subnet.app[count.index].id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  iam_instance_profile = aws_iam_instance_profile.app_profile.name

  associate_public_ip_address = false

  # Enable detailed monitoring
  monitoring = true

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypted Windows system disk
  root_block_device {
    volume_size = 150
    volume_type = "gp3"
    encrypted   = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]

  tags = {
    Name = "HawkerCare-OutSystems-App-${count.index + 1}"
    Role = "OutSystems-Application-Server"
    Tier = "Application"
  }
}
