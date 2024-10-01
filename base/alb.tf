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