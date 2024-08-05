
resource "aws_launch_template" "ghost_launch_template" {
  name          = "ghost"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ghost_ec2_pool.key_name

  vpc_security_group_ids = [aws_security_group.ec2_pool.id]
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

  user_data = base64encode(<<-EOF_USER_DATA
#!/bin/bash -xe

exec > >(tee /var/log/cloud-init-output.log | logger -t user-data -s 2>/dev/console) 2>&1
### Update this to match your ALB DNS name
LB_DNS_NAME="${aws_lb.alb_ghost.dns_name}"
###

REGION=$$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$$//')
EFS_ID=$$(aws efs describe-file-systems --query 'FileSystems[?Name==\`ghost_content\`].FileSystemId' --region $$REGION --output text)

### Install pre-reqs
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
yum install -y nodejs amazon-efs-utils
npm install ghost-cli@latest -g

adduser ghost_user
usermod -aG wheel ghost_user
cd /home/ghost_user/

sudo -u ghost_user ghost install [4.12.1] local

### EFS mount
mkdir -p /home/ghost_user/ghost/content/data
mount -t efs -o tls $$EFS_ID:/ /home/ghost_user/ghost/content

cat > /home/ghost_user/config.development.json <<-EOF_CONFIG
{
  "url": "http://$$LB_DNS_NAME",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "sqlite3",
    "connection": {
      "filename": "/home/ghost_user/ghost/content/data/ghost-local.db"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "local",
  "paths": {
    "contentPath": "/home/ghost_user/ghost/content"
  }
}
EOF_CONFIG

sudo -u ghost_user ghost stop
sudo -u ghost_user ghost start
EOF_USER_DATA
  )
}

resource "aws_autoscaling_group" "ghost_ec2_pool" {
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

  target_group_arns = [aws_lb_target_group.ghost_ec2.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "ghost-instance"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_target_group.ghost_ec2
  ]
}