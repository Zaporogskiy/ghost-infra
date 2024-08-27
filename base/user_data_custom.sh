#!/bin/bash
# Update all packages
sudo dnf update -y

# Install Apache HTTP Server
sudo dnf install -y httpd

# Configure Apache to listen on port 2368
echo "Listen 2368" > /etc/httpd/conf.d/listen.conf

# Set the default web page
echo "Hello from Artem's Server!" > /var/www/html/index.html

# Start the httpd service
systemctl start httpd

# Enable httpd to start on boot
systemctl enable httpd

# Open port 2368 on the firewall
firewall-cmd --permanent --add-port=2368/tcp
firewall-cmd --reload

# Verify and display status of port 2368, check if it's listening
echo "Checking port 2368 status:"
netstat -tuln | grep ":2368"

# Install MariaDB client
sudo dnf install -y mariadb105

# Try to connect to RDS MySQL
echo "Attempting to connect to RDS MySQL..."
mysql -h ghost.cd5ktj5z6krz.us-east-1.rds.amazonaws.com -P 3306 -u rootroot -prootroot -D ghostdb -e "STATUS;" && echo "Connection to RDS MySQL successful." || echo "Failed to connect to RDS MySQL."