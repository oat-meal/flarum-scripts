#!/bin/bash

#Please read instructions for proper use of this script.
#This script has been tested on Ubuntu 14.04 x64 systems
#
#
#You *should* CHANGE the MYSQL root password "LINES 38-39" This password will be requested "Line 77"
#
#
#chmod +x flarum-install.sh
#
#sudo ./flarum-install.sh


echo "###################################################################################"
echo "Please be Patient: Installation will some time, hope you read the notes..."
echo "###################################################################################"

sleep 3

#Update & Upgrade base system and packages.

sudo apt-get -y update && -y apt-get upgrade

#Install Unzip.

sudo apt-get -y install unzip

#Apache, Php, MySQL and required packages installation.

sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt php5-curl php5-mysql php5-gd php5-cli php5-dev mysql-client
php5enmod mcrypt

#The following commands set the MySQL root password to FLARUMMYsqlpassword when you install the mysql-server package.

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password FLARUMMYsqlpassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password FLARUMMYsqlpassword'
sudo apt-get -y install mysql-server

#Set FQDN for apache2.

echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
sudo a2enconf fqdn

#Make Directories.

echo "Creating Directory for Flarum"
sleep 2
sudo mkdir /var/www/flarum


#Download and extract Flarum - URL MAY CHANGE WITH NEW RELEASES!

echo "Downloading & extracting Flarum"
sleep 2
sudo wget --output-document="/var/www/flarum/temp.zip" https://github.com/flarum/flarum/releases/download/v0.1.0-beta/flarum-0.1.0-beta.zip
sudo unzip /var/www/flarum/temp.zip -d  /var/www/flarum
sudo rm -f /var/www/flarum/temp.zip

#Set Permissions.

sudo chown -R www-data:www-data /var/www/flarum

#Update apache2 settings.

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/flarum-beta.conf
sudo ln -s /etc/apache2/sites-available/flarum-beta.conf /etc/apache2/sites-enabled
sudo rm -f /etc/apache2/sites-enabled/000-default.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/flarum|' /etc/apache2/sites-available/flarum-beta.conf
sudo a2enmod rewrite
echo "<Directory "/var/www/flarum">" >> /etc/apache2/sites-enabled/flarum-beta.conf
echo "AllowOverride All" >> /etc/apache2/sites-enabled/flarum-beta.conf
echo "</Directory>" >> /etc/apache2/sites-enabled/flarum-beta.conf

#Create DB & User for Flarum - Be sure to record your credentials. Use the MYSQL root password you created above.

echo -n "Enter the MySQL root password: "
read -s rootpw
echo -n "Enter database name: "
read dbname
echo -n "Enter database username: "
read dbuser
echo -n "Enter database user password: "
read dbpw
 
db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"
 
if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
 echo "------------------------------------------"
 echo " Database has been created successfully "
 echo "------------------------------------------"
 echo " DB Info: "
 echo ""
 echo " DB Name: $dbname"
 echo " DB User: $dbuser"
 echo " DB Pass: $dbpw"
 echo ""
 echo "------------------------------------------"
fi

#Restart all the installed services to verify that things are working.

echo -e "\n"

service apache2 restart && service mysql restart > /dev/null

echo -e "\n"

if [ $? -ne 0 ]; then
   echo "Please Check the Installed Services, There are some $(tput bold)$(tput setaf 1)Problems$(tput sgr0)"
else
   echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
fi
