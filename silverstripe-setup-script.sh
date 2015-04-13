#!/usr/bin/env bash

## Extra requirements
sudo apt-get update 2> /dev/null
sudo apt-get install -q -y git curl realpath php5-curl php5-tidy php5-cli php5-mcrypt 2> /dev/null

## MySQL
echo mysql-server-5.1 mysql-server/root_password password admin | debconf-set-selections
echo mysql-server-5.1 mysql-server/root_password_again password admin | debconf-set-selections
sudo apt-get install -q -y mysql-server

## Phpmyadmin
echo phpmyadmin phpmyadmin/dbconfig-install boolean true | debconf-set-selections
echo phpmyadmin phpmyadmin/app-password-confirm password admin | debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/admin-pass password admin | debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/app-pass password admin | debconf-set-selections
echo phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2 | debconf-set-selections
sudo apt-get -q -y install phpmyadmin

## Configure appache and php5
sudo sed -i "s,DocumentRoot /var/www/html,DocumentRoot /var/www/,g" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s,AllowOverride None, AllowOverride All,g" /etc/apache2/apache2.conf
sudo sed -i "s,;date.timezone =,date.timezone = Pacific/Auckland,g" /etc/php5/apache2/php.ini
sudo sed -i "s,display_errors = Off,display_errors = On,g" /etc/php5/apache2/php.ini
sudo sed -i "s,display_startup_errors = Off,display_startup_errors = On,g" /etc/php5/apache2/php.ini
sudo a2enmod rewrite 2> /dev/null
sudo php5enmod mcrypt 2> /dev/null
sudo service apache2 reload 2> /dev/null
sudo chmod -R 777 /var/www/
sudo chown -R 777:777 /var/www/

## Composer
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
export COMPOSER_PROCESS_TIMEOUT=172800

## Configure git
sudo git config --global http.postBuffer 524288000
sudo git config --global credential.helper "cache --timeout=172800"

## Setup _ss_environment.php
sudo git clone https://gist.github.com/e24a8d8cca0f9163f31c.git /tmp/_ss_enviroment 2> /dev/null
sudo cp /tmp/_ss_enviroment/_ss_environment.php /var/

## Setup codebase
sudo cd /var/www
sudo composer create-project silverstripe/installer ./silverstripe
sudo cd silverstripe
sudo composer install 2> /dev/null
sudo composer update 2> /dev/null