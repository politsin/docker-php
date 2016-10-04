#!/bin/bash

#source /mysql-init.sh

# Disable Strict Host checking for non interactive git clones
mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config  
echo "Europe/Moscow" > /etc/timezone                     
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime 

#git 
git config --global user.email "politsin@gmail.com"
git config --global user.name  "Anatoly Politsin"

# www-data user
usermod -d /var/www/ www-data
chsh -s /bin/bash www-data
chown www-data.www-data /var/www/
chown www-data.www-data /var/www/.bash_profile
chown www-data.www-data /var/www/.bashrc
chown -Rf www-data.www-data /var/www/.ssh

chmod 600 /var/www/.ssh/authorized_keys
chown -Rf www-data.www-data /var/www/html/
chown -Rf www-data.www-data /var/www/.drush
chown -Rf www-data.www-data /var/www/.console

# php-fpm socket
mkdir -p /run/php/
chmod -R 0755 /run/php/
chown -R www-data.www-data /var/run/php
# mysql socket
chmod -R 0777 /var/run/mysqld

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
