resource "aws_lb" "alb_ghost" {
  name               = "alb-ghost"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.artem_public_subnet_a.id, aws_subnet.artem_public_subnet_b.id, aws_subnet.artem_public_subnet_c.id]
}

resource "aws_lb_target_group" "ghost_fargate_tg" {
  name        = "ghost-fargate"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.artem_vpc.id
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
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_ghost.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost_fargate_tg.arn
  }
}

resource "aws_lb_listener_rule" "weighted_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type = "forward"
    forward {

      target_group {
        arn    = aws_lb_target_group.ghost_fargate_tg.arn
        weight = 100
      }
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}