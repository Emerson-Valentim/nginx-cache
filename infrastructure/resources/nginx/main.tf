data "external" "encode" {
  program = ["${path.module}/encode.sh"]
}

locals {
  base64 = data.external.encode.result["base64_encoded_content"]
}

resource "aws_lb" "proxy" {
  name = "proxy-cache"

  internal           = false
  load_balancer_type = "application"

  subnets         = var.public_subnets
  security_groups = var.lb_sg_ids
}

resource "aws_lb_target_group" "cache" {
  name     = "ec2-cache"
  port     = 443
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.proxy.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cache.arn
  }
}

resource "aws_route53_record" "proxy" {
  zone_id = var.hosted_zone_id
  name    = "proxy_cache.evshosting.net"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.proxy.dns_name]
}


resource "aws_iam_instance_profile" "ec2" {
  name = "ec2"
  role = aws_iam_role.efs_access_role.name
}

resource "aws_iam_role" "efs_access_role" {
  name = "efs_access_role"

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "elasticfilesystem:*"
          ],
          Resource = "*"
        },
      ]
    })
  }

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
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = var.efs_id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/var/cache/nginx/service-cache"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "7777"
    }
  }
}

resource "aws_instance" "nginx" {
  count         = length(var.subnet_ids)
  ami           = "ami-041feb57c611358bd"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  iam_instance_profile = aws_iam_instance_profile.ec2.id

  tags = {
    project = "nginx-cache"
  }

  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
  #!/bin/bash
  wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

  sudo yum -y install amazon-cloudwatch-agent
  sudo rpm -U ./amazon-cloudwatch-agent.rpm
  msiexec /i amazon-cloudwatch-agent.msi

  sudo yum -y install epel-release
  sudo yum -y update
  sudo yum -y install nginx

  sudo yum install -y amazon-efs-utils
  sudo mkdir -p -m 777 /var/cache/nginx/service-cache
  sudo mount -t efs -o tls,accesspoint=${aws_efs_access_point.access_point.id} ${var.efs_id}:/ /var/cache/nginx/service-cache
  
  sudo chmod 775 /var/cache/nginx/service-cache

  sudo echo ${local.base64} | base64 -d  > /etc/nginx/nginx.conf
  sudo sed -i 's/$${APP}/${var.app_ip}/g' /etc/nginx/nginx.conf

  sudo nginx
  sudo systemctl enable nginx
  EOF
}

resource "aws_lb_target_group_attachment" "lb_attach" {
  count = length(aws_instance.nginx)

  target_group_arn = aws_lb_target_group.cache.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 8080
}
