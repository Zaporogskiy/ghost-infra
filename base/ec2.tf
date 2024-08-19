
resource "aws_launch_template" "ghost_launch_template" {
  name          = "ghost"
  image_id      = data.aws_ami.amazon_linux_x86_64.id
  instance_type = "t3.micro"
  key_name      = data.aws_key_pair.ghost_ec2_pool.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_pool_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ghost_app.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "ghost-instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    LB_DNS_NAME = aws_lb.alb_ghost.dns_name
  }))
}

resource "aws_autoscaling_group" "ghost_ec2_pool_asg" {
  name = "ghost_ec2_pool"

  launch_template {
    id      = aws_launch_template.ghost_launch_template.id
    version = "$Latest"
  }

  min_size = 1
  max_size = 10

  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id
  ]

  target_group_arns = [aws_lb_target_group.ghost_ec2_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "ghost-instance"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_target_group.ghost_ec2_tg
  ]
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_x86_64.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.ghost_ec2_pool.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.public_a.id

  tags = merge(local.tags, {
    Name = "bastion"
  })
}