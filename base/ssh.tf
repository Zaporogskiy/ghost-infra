
resource "aws_key_pair" "ghost-ec2-pool" {
  key_name   = "ghost-ec2-pool"
  public_key = var.ssh_key
  tags       = local.tags
}