data "http" "myip" {
  url = "https://api.ipify.org"
}

data "aws_key_pair" "ghost_ec2_pool" {
  key_name = "ghost-ec2-pool"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}