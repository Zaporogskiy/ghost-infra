#!/bin/bash -xe

exec > >(tee /var/log/cloud-init-output.log|logger -t user-data -s 2>/dev/console) 2>&1
### Update this to match your ALB DNS name
export LB_DNS_NAME='${LB_DNS_NAME}'
###

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(/usr/bin/curl http://169.254.169.254/latest/meta-data/placement/region -H "X-aws-ec2-metadata-token: $TOKEN")
EFS_ID=$(aws efs describe-file-systems --query 'FileSystems[?Name==`ghost_content`].FileSystemId' --region $REGION --output text)

### Install pre-reqs
curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
yum install -y nodejs amazon-efs-utils
npm install ghost-cli@latest -g

adduser ghost_user
usermod -aG wheel ghost_user
cd /home/ghost_user/

sudo -u ghost_user ghost install [5.82.3] local

### EFS mount
mkdir -p /home/ghost_user/ghost/content/data
mount -t efs -o tls $EFS_ID:/ /home/ghost_user/ghost/content

sudo chown -R ghost_user:ghost_user /home/ghost_user/ghost/content
sudo chmod -R 777 /home/ghost_user/ghost/content

sudo chown -R ghost_user:ghost_user /home/ghost_user/ghost/content/data
sudo chmod -R 777 /home/ghost_user/ghost/content/data

cat << EOF > config.development.json

{
  "url": "http://${LB_DNS_NAME}",
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
EOF

sudo -u ghost_user ghost stop
sudo -u ghost_user ghost start