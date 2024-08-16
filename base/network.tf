resource "aws_vpc" "cloudx" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = local.availability_zone_a
  tags = merge(local.tags, {
    Name = local.public_subnet_1
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = local.availability_zone_b
  tags = merge(local.tags, {
    Name = local.public_subnet_2
  })
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = local.availability_zone_c
  tags = merge(local.tags, {
    Name = local.public_subnet_3
  })
}

resource "aws_internet_gateway" "cloudx_igw" {
  vpc_id = aws_vpc.cloudx.id

  tags = merge(local.tags, {
    Name = "cloudx-igw"
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

resource "aws_lb" "alb_ghost" {
  name               = "alb-ghost"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(local.tags, {
    Name = "alb-ghost"
  })
}

resource "aws_lb_target_group" "ghost_ec2_tg" {
  name     = "ghost-ec2"
  port     = 2368
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudx.id

  health_check {
    port                = "2368"
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = merge(local.tags, {
    Name = "ghost-ec2"
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

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.ghost_ec2_tg.arn
        weight = 100
      }

      stickiness {
        enabled  = true
        duration = 300
      }
    }
  }

  condition {
    source_ip {
      values = ["${chomp(data.http.myip.response_body)}/32"]
    }
  }
  tags = local.tags
}