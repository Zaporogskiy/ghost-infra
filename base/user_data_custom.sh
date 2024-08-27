#!/bin/bash
# Install Apache HTTP server
yum install -y httpd

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