resource "aws_vpc" "cloudx" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}

resource "aws_internet_gateway" "cloudx_igw" {
  vpc_id = aws_vpc.cloudx.id

  tags = merge(local.tags, {
    Name = "cloudx-igw"
  })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = local.public_subnet_1
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = local.public_subnet_2
  })
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = local.public_subnet_3
  })
}

resource "aws_subnet" "private_db_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.20.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_db_subnet_1
  })
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.21.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_db_subnet_2
  })
}

resource "aws_subnet" "private_db_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.22.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_db_subnet_3
  })
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_1
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.11.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_2
  })
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.12.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_3
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloudx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx_igw.id
  }

  tags = merge(local.tags, {
    Name = "public_rt"
  })
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cloudx.id

  tags = merge(local.tags, {
    Name = "private_rt"
  })
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_c_association" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_c_association" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_a_association" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_b_association" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_c_association" {
  subnet_id      = aws_subnet.private_db_c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_lb" "alb_ghost" {
  name               = "alb-ghost"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]

  tags = merge(local.tags, {
    Name = "alb-ghost"
  })
}

resource "aws_lb_target_group" "ghost_ec2_tg" {
  name        = "ghost-ec2"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudx.id
  target_type = "instance"
  slow_start  = "600"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 120
    matcher             = "200"
  }

  tags = merge(local.tags, {
    Name = "ghost-ec2"
  })
}

resource "aws_lb_target_group" "ghost_fargate_tg" {
  name        = "ghost-fargate"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudx.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 120
    matcher             = "200"
  }

  tags = merge(local.tags, {
    Name = "ghost-fargate"
  })
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_ghost.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost_ec2_tg.arn
  }
  tags = local.tags
}

resource "aws_lb_listener_rule" "weighted_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.ghost_ec2_tg.arn
        weight = 50
      }

      target_group {
        arn    = aws_lb_target_group.ghost_fargate_tg.arn
        weight = 50
      }
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_db_subnet_group" "ghost" {
  name        = "ghost"
  description = "ghost database subnet group"
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id, aws_subnet.private_db_c.id]

  tags = local.tags
}

# SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]

  tags = {
    Name = "ssm-endpoint"
  }
}
# ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]

  tags = {
    Name = "ecr-api-endpoint"
  }
}
# ECR DKR
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

# EFS
resource "aws_vpc_endpoint" "efs" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.elasticfilesystem"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]

  tags = {
    Name = "efs-endpoint"
  }
}
# CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]

  tags = {
    Name = "logs-endpoint"
  }
}
# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cloudx.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = {
    Name = "s3-endpoint"
  }
}