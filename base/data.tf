data "http" "myip" {
  url                = "http://ifconfig.me/ip"
  request_timeout_ms = 5000
}

data "aws_key_pair" "ghost_ec2_pool" {
  key_name = "ghost-ec2-pool"
}

data "aws_ami" "amazon_linux_x86_64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_caller_identity" "current" {}