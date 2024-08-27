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
    Name = local.private_subnet_1
  })
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.21.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_2
  })
}

resource "aws_subnet" "private_db_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.22.0/24"
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