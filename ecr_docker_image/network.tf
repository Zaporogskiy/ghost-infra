resource "aws_vpc" "artem_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "artem_public_subnet_a" {
  vpc_id                  = aws_vpc.artem_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artem_private_subnet_1" {
  vpc_id     = aws_vpc.artem_vpc.id
  cidr_block = "10.0.2.0/24"
}