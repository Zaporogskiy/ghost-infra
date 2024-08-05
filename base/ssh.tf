
resource "aws_key_pair" "ghost_ec2_pool" {
  key_name   = "ghost-ec2-pool"
  public_key = var.ssh_key
  tags       = local.tags
}