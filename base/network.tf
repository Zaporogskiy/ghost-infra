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
    Name = local.private_db_subnet_1
  })
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.21.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_db_subnet_2
  })
}

resource "aws_subnet" "private_db_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.22.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_db_subnet_3
  })
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_1
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.11.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = local.private_subnet_2
  })
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.12.0/24"
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

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_c_association" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
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

resource "aws_db_subnet_group" "ghost" {
  name        = "ghost"
  description = "ghost database subnet group"
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id, aws_subnet.private_db_c.id]

  tags = local.tags
}

# VPC Endpoints
# ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.cloudx.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
}
# ECR DKR
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.cloudx.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
}
# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cloudx.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_rt.id]
}
# CloudWatch Logs
resource "aws_vpc_endpoint" "ecr_logs" {
  vpc_id              = aws_vpc.cloudx.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]

  tags = {
    Name = "logs-endpoint"
  }
}
# SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.cloudx.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]

  tags = {
    Name = "ssm-endpoint"
  }
}