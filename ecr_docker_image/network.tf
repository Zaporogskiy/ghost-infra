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

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags = merge(local.tags, {
    Name = "nat-gateway"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "nat-eip"
  })
}

resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.cloudx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.tags, {
    Name = "private-rt-a"
  })
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.cloudx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.tags, {
    Name = "private-rt-b"
  })
}

resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.cloudx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.tags, {
    Name = "private-rt-c"
  })
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

resource "aws_route_table_association" "private_c_association" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt_c.id
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

# ECR API Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  private_dns_enabled = true
}

# ECR Docker Registry Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cloudx.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt_a.id, aws_route_table.private_rt_b.id, aws_route_table.private_rt_c.id]
}