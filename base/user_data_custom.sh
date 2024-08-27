#!/bin/bash

export DB_HOST="${DB_HOST}"
export DB_NAME="${DB_NAME}"

DB_USER=$(aws ssm get-parameter --name "/ghost/username" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/ghost/dbpassw" --with-decryption --query "Parameter.Value" --output text)
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Failed to retrieve DB credentials."
  exit 1
fi

sudo dnf update -y
sudo dnf install -y httpd
sudo dnf install -y mariadb105

echo "Listen 2368" > /etc/httpd/conf.d/listen.conf
echo "Hello from Artem's Server!" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd

firewall-cmd --permanent --add-port=2368/tcp
firewall-cmd --reload

echo "Checking port 2368 status:"
netstat -tuln | grep ":2368"

echo "Attempting to connect to RDS MySQL..."
mysql -h "$DB_HOST" -P 3306 -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "STATUS;" && echo "Connection to RDS MySQL successful." || echo "Failed to connect to RDS MySQL."