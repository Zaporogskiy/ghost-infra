resource "aws_vpc" "artem_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cloudx_igw" {
  vpc_id = aws_vpc.artem_vpc.id
}

resource "aws_subnet" "artem_public_subnet_a" {
  vpc_id                  = aws_vpc.artem_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artem_private_subnet_1" {
  vpc_id     = aws_vpc.artem_vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.artem_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx_igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.artem_vpc.id
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.artem_public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.artem_private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

# todo ---- VPC Endpoints ------
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.artem_vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.artem_private_subnet_1.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.artem_vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.artem_private_subnet_1.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.artem_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_rt.id]
}

# CloudWatch Logs
resource "aws_vpc_endpoint" "ecr_logs" {
  vpc_id              = aws_vpc.artem_vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
  subnet_ids          = [aws_subnet.artem_private_subnet_1.id]

  tags = {
    Name = "logs-endpoint"
  }
}
# SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.artem_vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ecr_vpc_endpoint_sg.id]
  subnet_ids          = [aws_subnet.artem_private_subnet_1.id]

  tags = {
    Name = "ssm-endpoint"
  }
}