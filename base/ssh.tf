
resource "aws_key_pair" "ghost-tf-ssh-key" {
  key_name   = "ghost-tf-ssh-key"
  public_key = var.ssh_key
  tags       = local.tags
}