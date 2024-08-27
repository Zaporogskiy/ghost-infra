resource "aws_efs_file_system" "ghost_content" {
  creation_token = "ghost_content"
  tags = merge(local.tags, {
    Name = "ghost_content"
  })
}

resource "aws_efs_mount_target" "mount_target_a" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_target_b" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_target_c" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_c.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_db_instance" "ghost" {
  identifier        = "ghost"
  instance_class    = "db.t2.micro"
  engine            = "mysql"
  engine_version    = "8.0"
  storage_type      = "gp2"
  allocated_storage = 20

  db_subnet_group_name = aws_db_subnet_group.ghost.name
  vpc_security_group_ids = [aws_security_group.mysql.id]

  tags = local.tags
}