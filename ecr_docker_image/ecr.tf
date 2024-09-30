resource "aws_ecr_repository" "artem_app" {
  name                 = "artem_app"
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE", based on your needs

  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "null_resource" "docker_image" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = <<EOT
      #!/bin/bash
      set -e

      # Define variables
      REGION="us-east-1"
      ACCOUNT_ID="595140864345"
      REPOSITORY_NAME="artem_app"
      IMAGE_VERSION="4.12.1"

      # Login to AWS ECR
      aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME

      # Build the Docker image from a Dockerfile in the current directory
      docker build -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION .

      # Push the Docker image to ECR
      docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_ecr_repository.artem_app]
}