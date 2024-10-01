resource "aws_ecs_cluster" "ghost" {
  name = "ghost"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task_def_ghost" {
  family                   = "task_def_ghost"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ghost_ecs_role.arn
  cpu                      = "256"
  memory                   = "1024"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "ghost_container"
      image     = "${aws_ecr_repository.ghost.repository_url}:4.12.1"
      essential = true
      portMappings = [
        {
          containerPort = 2368
          hostPort      = 2368
          protocol      = "tcp"
        },
      ],
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/artem_task_logs",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ghost" {
  name            = "ghost"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.task_def_ghost.arn
  desired_count   = 1

  network_configuration {
    assign_public_ip = false
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    security_groups  = [aws_security_group.fargate_pool.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost_fargate_tg.arn
    container_name   = "ghost_container"
    container_port   = 2368
  }

  launch_type = "FARGATE"
}