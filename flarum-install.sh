#!/bin/bash

clear

echo "Starting Script"
sleep 2
echo "Update && Upgrade"
sleep 2
apt-get update && apt-get upgrade -y
sleep 1
echo "Installing LAMP & Unzip"
sleep 2
echo "MY SQL automation"

## Replace "root_password password your_mysql_root_password" with your password.

echo "mysql-server-5.1 mysql-server/root_password password your_mysql_root_password" | debconf-set-selections
echo "mysql-server-5.1 mysql-server/root_password_again password your_mysql_root_password" | debconf-set-selections

apt-get install unzip apache2 apache2-utils mysql-server libapache2-mod-auth-mysql php5-mysql php5 php5-mysql php-pear php5-gd  php5-mcrypt php5-curl


echo "I hope that worked?"
