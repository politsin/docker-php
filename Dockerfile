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
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php7.1 \
                       php7.1-gd  \
                       php7.1-bz2 \
                       php7.1-fpm \
                       php7.1-dev \
                       php7.1-zip \
                       php7.1-cgi \
                       php7.1-soap \
                       php7.1-curl \
                       php7.1-json \
                       php7.1-imap \
                       php7.1-mysql \
                       php7.1-pgsql \
                       php7.1-xmlrpc \
                       php7.1-mcrypt \
                       php7.1-bcmath \
                       php7.1-opcache \
                       php7.1-mbstring \
                       php-pear \
                       php-ssh2 \
                       php-redis \
                       php-sqlite3 \
                       php-imagick \
                       php-memcached \
                       php-codesniffer \
                       supervisor \
                       mysql-client \
                       openssh-server \
                       postgresql-client \
                       mc \
                       git \
                       zip \
                       cron \
                       curl \
                       htop \
                       nano \
                       sass \
                       sudo \
                       putty \
                       ssmtp \
                       unzip \
                       screen \
                       sshpass \
                       composer \
                       net-tools \
                       imagemagick \
                       libxrender1 \
                       inetutils-ping \
                       software-properties-common && \
    apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    mkdir /var/run/sshd && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

#PhpCS:::
RUN cd ~ && \
  git clone https://git.drupal.org/project/coder.git && \
  mv /root/coder/coder_sniffer/DrupalPractice /usr/share/php/PHP/CodeSniffer/Standards/DrupalPractice && \
  mv /root/coder/coder_sniffer/Drupal /usr/share/php/PHP/CodeSniffer/Standards/Drupal && \
  rm -rf /root/coder

#Uploadprogress:::
RUN wget https://github.com/Jan-E/uploadprogress/archive/master.zip && \
    unzip master.zip && \
    cd uploadprogress-master/ && \
    phpize && ./configure --enable-uploadprogress && \
    make && make install && \
    echo 'extension=uploadprogress.so' > /etc/php/7.1/mods-available/uploadprogress.ini && \
    ln -s /etc/php/7.1/mods-available/uploadprogress.ini /etc/php/7.1/fpm/conf.d/20-uploadprogress.ini && \
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

#Composer:::
RUN wget https://getcomposer.org/composer.phar -q -O composer.phar \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer

#NodeJS:::
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    apt-get install -y nodejs && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean

#Gulp:::
RUN npm install gulpjs/gulp-cli -g && \
    npm install gulpjs/gulp#4.0 --save-dev

#GulpPacs:::
RUN npm install gulp-sass && \
    npm install gulp-watch && \
    npm install gulp-touch && \
    npm install gulp-touch-cmd && \
    npm install gulp-plumber

#COPY script & config:::
COPY config/php/www.conf /etc/php/7.1/fpm/pool.d/www.conf
COPY config/php/php.ini /etc/php/7.1/fpm/php.ini
COPY config/php/opcache.ini /etc/php/7.1/mods-available/opcache.ini
COPY config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY config/cron/www-data /var/spool/cron/crontabs/www-data
COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/start.sh /start.sh

#Fix ownership
RUN chmod 755 /start.sh && \
    mkdir /run/php && \
    chown -R www-data.www-data /run/php && \
    chown www-data.www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data

# Expose Ports
EXPOSE 22

ENTRYPOINT ["/start.sh"]
