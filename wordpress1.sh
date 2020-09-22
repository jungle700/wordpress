

#!/bin/bash

sudo yum update -y
sudo yum install httpd -y 
sudo systemctl start httpd 
sudo systemctl enable httpd
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata -y
sudo yum install php-cli php-pdo php-fpm php-json php-mysqlnd -y
sudo systemctl restart httpd
sudo yum install -y mysql
cd /var/www/html
sudo wget http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
mv wordpress/* .
rm -rf wordpress *.gz
sudo cp wp-config-sample.php wp-config.php

