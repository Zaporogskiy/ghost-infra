resource "aws_ecs_cluster" "artem_cluster" {
  name = "artem_cluster"
}

resource "aws_ecs_task_definition" "artem_task" {
  family                   = "artem_task_family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "artem_app"
      image     = "${aws_ecr_repository.artem_app.repository_url}:4.12.1"
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

resource "aws_ecs_service" "artem_service" {
  name            = "artem_service"
  cluster         = aws_ecs_cluster.artem_cluster.id
  task_definition = aws_ecs_task_definition.artem_task.arn
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost_fargate_tg.arn
    container_name   = "artem_app"
    container_port   = 2368
  }

  launch_type = "FARGATE"
}