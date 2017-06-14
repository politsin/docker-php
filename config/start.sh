#!/bin/bash

# Disable Strict Host checking for non interactive git clones
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config 

mkdir -p -m 0700 /root/.ssh
echo "Europe/Moscow" > /etc/timezone                     
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# www-data user
usermod -d /var/www/ www-data
chsh -s /bin/bash www-data
chown www-data.www-data /var/www/
chown www-data.www-data /var/www/.bash_profile
chown www-data.www-data /var/www/.bashrc
chmod 600 /var/www/.ssh/authorized_keys
chown -Rf www-data.www-data /var/www/.ssh
chown -Rf www-data.www-data /var/www/html/
chown -Rf www-data.www-data /var/www/.drush
chown -Rf www-data.www-data /var/www/.console

# cron
chown www-data.www-data /var/spool/cron/crontabs/www-data
chmod 0777 /var/spool/cron/crontabs
chmod 0600 /var/spool/cron/crontabs/www-data

# php-fpm socket
mkdir -p /run/php/
chmod -R 0755 /run/php/
chown -R www-data.www-data /run/php/

# db socket
chmod -R 0777 /var/run/mysqld
chmod -R 0777 /var/run/postgresql

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
