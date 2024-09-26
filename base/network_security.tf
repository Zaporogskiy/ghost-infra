resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "allows access to bastion"
  vpc_id      = aws_vpc.cloudx.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

resource "aws_security_group" "alb_sg" {
  name        = "alb"
  description = "allows access to alb"
  vpc_id      = aws_vpc.cloudx.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "ec2_pool_sg" {
  name        = "ec2_pool"
  description = "allows access to ec2 instances"
  vpc_id      = aws_vpc.cloudx.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cloudx.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "defines access to efs mount points"
  vpc_id      = aws_vpc.cloudx.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_pool_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.cloudx.cidr_block]
  }
  tags = local.tags
}

resource "aws_security_group" "fargate_pool" {
  name        = "fargate_pool"
  description = "Allows access for Fargate instances"
  vpc_id      = aws_vpc.cloudx.id

  # Ingress rule for HTTP traffic on port 2368 from ALB
  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Default egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group_rule" "efs_from_fargate" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.fargate_pool.id
}

# Rule for Fargate allowing access to EFS
resource "aws_security_group_rule" "fargate_to_efs" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate_pool.id
  source_security_group_id = aws_security_group.efs.id
}

resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "defines access to ghost db"
  vpc_id      = aws_vpc.cloudx.id

  # Ingress rule
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_pool_sg.id]
  }

  # New Ingress rule for Fargate
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.fargate_pool.id]
  }

  # Default egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}