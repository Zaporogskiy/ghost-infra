locals {
  tags = {
    Project = "Ghost"
    Owner   = "${var.engineer_name}_${var.engineer_surname}"
  }
}