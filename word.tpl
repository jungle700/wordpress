
#!/bin/bash


echo  "${database_host}" >  /tmp/test

cd /var/www/html/wordpress

sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/admin12/" wp-config.php
sed -i "s/password_here/wordpress2020/" wp-config.php
sed -i "s/localhost/$(cat /tmp/test)/" wp-config.php

cd /home/ec2-user

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

tar xvf node_exporter-1.0.1.linux-amd64.tar.gz

cd /home/ec2-user/node_exporter-1.0.1.linux-amd64

./node_exporter &

echo test > /tmp/test2