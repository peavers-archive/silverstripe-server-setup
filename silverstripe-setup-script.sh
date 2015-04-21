#!/usr/bin/env bash

#==============
# Basic requirements
#==============
init() {

    sudo apt-get update

    # Install the bare minimum to get silverstripe to install successfully. Does not include the web stack
    sudo apt-get install -q -y git curl realpath php5-curl php5-tidy php5-cli php5-mcrypt

    # Call the main menu
    main

}

#==============
# Mysql & Php
#==============
webstack() {

    # MySQL
    echo mysql-server-5.1 mysql-server/root_password password admin | debconf-set-selections
    echo mysql-server-5.1 mysql-server/root_password_again password admin | debconf-set-selections
    sudo apt-get install -q -y mysql-server

    # Phpmyadmin
    echo phpmyadmin phpmyadmin/dbconfig-install boolean true | debconf-set-selections
    echo phpmyadmin phpmyadmin/app-password-confirm password admin | debconf-set-selections
    echo phpmyadmin phpmyadmin/mysql/admin-pass password admin | debconf-set-selections
    echo phpmyadmin phpmyadmin/mysql/app-pass password admin | debconf-set-selections
    echo phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2 | debconf-set-selections
    sudo apt-get -q -y install phpmyadmin

    # Configure appache and php5
    sudo sed -i "s,DocumentRoot /var/www/html,DocumentRoot /var/www/,g" /etc/apache2/sites-available/000-default.conf
    sudo sed -i "s,AllowOverride None, AllowOverride All,g" /etc/apache2/apache2.conf
    sudo sed -i "s,;date.timezone =,date.timezone = Pacific/Auckland,g" /etc/php5/apache2/php.ini
    sudo sed -i "s,display_errors = Off,display_errors = On,g" /etc/php5/apache2/php.ini
    sudo sed -i "s,display_startup_errors = Off,display_startup_errors = On,g" /etc/php5/apache2/php.ini
    sudo a2enmod rewrite 2 > /dev/null
    sudo php5enmod mcrypt 2 > /dev/null
    sudo service apache2 reload 2 > /dev/null
    sudo chmod -R 777 /var/www/
    sudo chown -R 777:777 /var/www/

}

#==============
# Silverstripe tools
#==============
tools() {

    # Composer
    sudo curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    export COMPOSER_PROCESS_TIMEOUT=172800

    # Sspak
    sudo curl -sS http://silverstripe.github.io/sspak/install | php -- /usr/local/bin

    # Setup _ss_environment.php
    sudo git clone https://gist.github.com/e24a8d8cca0f9163f31c.git /tmp/_ss_enviroment 2 > /dev/null
    sudo cp /tmp/_ss_enviroment/_ss_environment.php /var/

}

#==============
# Set permissions
#==============
permissions() {

    sudo chgrp -R www-data /var/www
    sudo chmod -R g+w /var/www
    sudo find /var/www -type d -exec chmod 2775 {} \;
    sudo find /var/www -type f -exec chmod ug+rw {} \;

}

#==============
# Configure Git
#==============
git() {

    # Configure git
    sudo git config --global http.postBuffer 524288000
    sudo git config --global credential.helper "cache --timeout=172800"

}

#==============
# Create first project
#==============
project() {

    sudo cd /var/www
    sudo composer create-project silverstripe/installer ./silverstripe
    sudo cd silverstripe
    sudo composer install 2 > /dev/null
    sudo composer update 2 > /dev/null

}

#==============
# Run everything!
#==============
all() {

    webstack
    tools
    permissions
    git
    project

}

#==============
# Menu
#==============
main() {

    clear

    until [ "$REPLY" = "q" ]; do
        echo '#-----------------------------------------------#'
        echo '#   Silverstripe server                         #'
        echo '#-----------------------------------------------#'
        echo ''
        echo '1.  Install webstack (mysql/php)'
        echo '2.  Tools (composer/sspak/_ss_environment)'
        echo '3.  Permissions'
        echo '4.  Configure git'
        echo '5.  Create base Silverstripe project'
        echo '0.  Install everything!'
        echo ''
        echo '#-----------------------------------------------#'
        echo 'q.  Quit'
        echo ''
        read -p 'Command : ' REPLY
        case $REPLY in
            1) clear && webstack ;;
            2) clear && tools ;;
            3) clear && permissions ;;
            4) clear && git ;;
            5) clear && project ;;
            0) clear && all ;;
            [Qq]*) clear && quit ;;
        esac
    done

}

#==============
# Fire the script off!
#==============
init
