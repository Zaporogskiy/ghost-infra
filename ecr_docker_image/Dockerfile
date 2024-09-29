# Use Amazon Linux 2 base image
FROM amazonlinux:2

# Update packages and install Apache
RUN yum update -y && \
    yum install -y httpd && \
    echo "Listen 2368" > /etc/httpd/conf.d/listen.conf && \
    echo "Hello from Artem's Server!" > /var/www/html/index.html && \
    chkconfig httpd on

# Expose port 2368
EXPOSE 2368

# Keep the Apache server running in the foreground
CMD ["httpd", "-D", "FOREGROUND"]