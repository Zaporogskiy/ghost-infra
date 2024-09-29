resource "aws_ecr_repository" "artem_ecr" {
  name = "ghost"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete = true
}

resource "null_resource" "docker_image" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = <<EOT
      # Exit on any error
      set -e
      # Login to AWS ECR
      LOGIN_CMD=$(aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ghost)
      if [ $? -ne 0 ]; then
        echo "Failed to login to Docker ECR"
        exit 1
      fi
      docker build -t ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ghost:4.12.1 .
      docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ghost:4.12.1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_ecr_repository.artem_ecr]
}

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
  task_role_arn            = aws_iam_role.ghost_ecs_role.arn
  execution_role_arn       = aws_iam_role.ghost_ecs_role.arn
  cpu                      = "256"
  memory                   = "1024"

  volume {
    name = "ghost_volume"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.ghost_content.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

  container_definitions = jsonencode([
    {
      name      = "ghost_container"
      image     = local.ecr_repository_uri
      essential = true
      environment = [
        { name : "database__client", value : "mysql" }
      ]
      mountPoints = [
        {
          containerPath = "/var/lib/ghost/content"
          sourceVolume  = "ghost_volume"
        }
      ]
      portMappings = [
        {
          containerPort = 2368
          hostPort      = 2368
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ghost" {
  name            = "ghost"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.task_def_ghost.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    security_groups  = ["${aws_security_group.fargate_pool.id}"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost_fargate_tg.arn
    container_name   = "ghost_container"
    container_port   = 2368
  }

  depends_on = [
    aws_lb_listener.alb_listener,
    aws_ecs_task_definition.task_def_ghost
  ]
}