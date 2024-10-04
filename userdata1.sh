#!/bin/bash

# Update package lists
apt-get update

# Install Apache
apt-get install -y apache2

# Set up a simple HTML page
echo "<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Web Server 2</title>
</head>
<body>
    <h1>Welcome</h1>
    <p>This is a simple web server 2 running on an EC2 instance.</p>
</body>
</html>" > /var/www/html/index.html

# Start Apache and enable it to start on boot
systemctl start apache2
systemctl enable apache2
