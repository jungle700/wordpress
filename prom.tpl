#!/bin/bash


# prometheus installation

cd /home/ec2-user

wget https://github.com/prometheus/prometheus/releases/download/v2.21.0/prometheus-2.21.0.linux-amd64.tar.gz

tar xvf prometheus-2.21.0.linux-amd64.tar.gz

cd /home/ec2-user/prometheus-2.21.0.linux-amd64

./prometheus &             




# node exporter installation

cd /home/ec2-user

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

tar xvf node_exporter-1.0.1.linux-amd64.tar.gz

cd /home/ec2-user/node_exporter-1.0.1.linux-amd64

./node_exporter &




# Grafana

cd /home/ec2-user

wget https://dl.grafana.com/oss/release/grafana-7.1.5.linux-amd64.tar.gz

tar -zxvf grafana-7.1.5.linux-amd64.tar.gz

cd grafana-7.1.5/bin

./grafana-server &   


