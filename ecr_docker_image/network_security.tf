resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs_tasks_sg"
  description = "Allow ECS tasks to communicate within the VPC"
  vpc_id      = aws_vpc.artem_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecr_vpc_endpoint_sg" {
  name        = "ecr_vpc_endpoint_sg"
  description = "Security Group for ECR VPC Endpoints"
  vpc_id      = aws_vpc.artem_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}