FROM ubuntu:16.04
MAINTAINER Synapse <mail@synapse-studio.ru>

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

#APT-GET:::
RUN apt-get update && \
    apt-get install -y software-properties-common apt-utils && \
    apt-get install -y php7.0 \
                       php7.0-gd  \
                       php7.0-bz2 \
                       php7.0-fpm \
                       php7.0-dev \
                       php7.0-zip \
                       php7.0-cgi \
                       php7.0-soap \
                       php7.0-curl \
                       php7.0-json \
                       php7.0-imap \
                       php7.0-mysql \
                       php7.0-pgsql \
                       php7.0-xmlrpc \
                       php7.0-mcrypt \
                       php7.0-bcmath \
                       php7.0-opcache \
                       php7.0-mbstring \
                       php-pear \
                       php-redis \
                       php-sqlite3 \
                       php-memcached \
                       supervisor \
                       mysql-client \
                       openssh-server \
                       postgresql-client \
                       mc \
                       git \
                       zip \
                       htop \
                       curl \
                       nano \
                       cron \
                       sass \
                       unzip \
                       ssmtp \
                       putty \
                       sshpass \
                       composer \
                       net-tools \
                       libxrender1 \
                       inetutils-ping && \
    apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    mkdir /var/run/sshd && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

#Uploadprogress:::
RUN wget https://github.com/Jan-E/uploadprogress/archive/master.zip && \
    unzip master.zip && \
    cd uploadprogress-master/ && \
    phpize && ./configure --enable-uploadprogress && \
    make && make install && \
    echo 'extension=uploadprogress.so' > /etc/php/7.0/mods-available/uploadprogress.ini && \
    ln -s /etc/php/7.0/mods-available/uploadprogress.ini /etc/php/7.0/fpm/conf.d/20-uploadprogress.ini && \
    cd .. && rm -rf ./master.zip ./uploadprogress-master

#DRUSH:::
RUN wget https://s3.amazonaws.com/files.drush.org/drush.phar -q -O drush \
    && php drush core-status \
    && chmod +x drush \
    && mv drush /usr/local/bin/drush

#Dupal-console:::
RUN wget https://drupalconsole.com/installer -q -O drupal.phar \
    && mv drupal.phar /usr/local/bin/drupal \
    && chmod +x /usr/local/bin/drupal

#NodeJS:::
RUN apt-get update && \
    apt-get install -y npm nodejs-legacy && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean

#Gulp:::
RUN npm install gulpjs/gulp-cli -g && \
    npm install gulpjs/gulp#4.0 --save-dev

#GulpPacs:::
RUN npm install gulp-sass && \
    npm install gulp-watch && \
    npm install gulp-plumber
    

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini

# ADD
ADD config/php/www.conf /etc/php/7.0/fpm/pool.d/www.conf
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/start.sh /start.sh

# fix ownership of sock file for php-fpm
RUN mkdir /run/php && \
    chown www-data.www-data /run/php && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Add run dir for ssh default config
RUN chmod 755 /start.sh

# Expose Ports
EXPOSE 22

ENTRYPOINT ["/start.sh"]
