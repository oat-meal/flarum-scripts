#!/bin/bash
#-------------------------------------------------------------------------------
#Created by cseiber mailto: christopher[dot]seiber[at]gmail[dot]com
#-------------------------------------------------------------------------------
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
#This script has been tested on Ubuntu 14.04 x64 systems.
#CHANGE the MYSQL root password where noted below.


#Update & Upgrade base system and packages.
sudo apt-get -y update && apt-get upgrade

#Install Unzip.
sudo apt-get -y install unzip

#Apache, Php, MySQL and required packages installation.
sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt php5-curl php5-mysql php5-gd php5-cli php5-dev mysql-client
php5enmod mcrypt

#Create DB & User for Flarum - Be sure to record your credentials. NOTE: Use the MySQL root password you created above.
echo -n "MySQL root password: "
read -s rootpw
echo -n "Flarum database username: "
read dbuser
echo -n "Database user password: "
read dbpw
echo -n "Database name: "
read dbname

#The following commands set the MySQL root password to FLARUMMySQLpassword when you install the mysql-server package. NOTE: Change & RECORD this password!
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbpw"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbpw"
sudo apt-get -y install mysql-server

#Set FQDN for apache2.
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
sudo a2enconf fqdn

#Make Directories.
sudo mkdir /var/www/flarum

#Download and extract Flarum - URL MAY CHANGE WITH NEW RELEASES!
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
