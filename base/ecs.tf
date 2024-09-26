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