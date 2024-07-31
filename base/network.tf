resource "aws_vpc" "main" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  tags = merge(local.tags, {
    Name = local.public_subnet_1
  })
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1b"
  tags = merge(local.tags, {
    Name = local.public_subnet_2
  })
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.5.0/24"
  availability_zone = "us-east-1c"
  tags = merge(local.tags, {
    Name = local.public_subnet_3
  })
}