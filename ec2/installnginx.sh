#!/bin/bash

HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)

sudo apt update
sudo apt install nginx -y
sed -i "s/nginx/OpsSchool Rules $HOSTNAME/g" /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html

sudo apt install awscli -y
echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://nginx-access-log-tf-hw3" > /var/spool/cron/crontabs/root
service nginx restart