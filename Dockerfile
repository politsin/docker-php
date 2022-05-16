FROM ubuntu:22.04
MAINTAINER Synapse <mail@synapse-studio.ru>

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# APT install:::
RUN sed -i -e 's/^APT/# APT/' -e 's/^DPkg/# DPkg/' \
      /etc/apt/apt.conf.d/docker-clean
RUN apt update -y && \
    apt install -y software-properties-common \
                   cron \
                   sudo \
                   ssmtp \
                   dnsutils \
                   net-tools \
                   apt-utils \
                   supervisor \
                   imagemagick \
                   openssh-server \
                   inetutils-ping \
                   php8.1 \
                   php8.1-gd  \
                   php8.1-bz2 \
                   php8.1-fpm \
                   php8.1-dev \
                   php8.1-zip \
                   php8.1-cgi \
                   php8.1-xml \
                   php8.1-dom \
                   php8.1-soap \
                   php8.1-curl \
                   php8.1-imap \
                   php8.1-intl \
                   php8.1-mysql \
                   php8.1-pgsql \
                   php8.1-xmlrpc \
                   php8.1-bcmath \
                   php8.1-opcache \
                   php8.1-mbstring \                   
                   php-apcu \
                   php-json \
                   php-pear \
                   php-ssh2 \
                   php-redis \
                   php-xdebug \
                   php-sqlite3 \
                   php-imagick \
                   php-memcached
# RUN apt install -y mc \
#                    git \
#                    nnn \
#                    zip \
#                    zsh \
#                    curl \
#                    htop \
#                    nano \
#                    ncdu \
#                    sass \
#                    putty \
#                    unzip \
#                    sshpass && \
#     apt-get clean
# RUN apt install -y sqlite3 \
#                    redis-tools \
#                    mysql-client \
#                    postgresql-client && \
#     apt-get clean
# RUN apt install -y awscli \
#                    python3-pip && \
#     apt-get clean
# RUN apt autoremove -y

#PHP:::
RUN apt update && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y php8.1 \
                   php8.1-gd  \
                   php8.1-bz2 \
                   php8.1-fpm \
                   php8.1-dev \
                   php8.1-zip \
                   php8.1-cgi \
                   php8.1-xml \
                   php8.1-dom \
                   php8.1-soap \
                   php8.1-curl \
                   php8.1-imap \
                   php8.1-intl \
                   php8.1-mysql \
                   php8.1-pgsql \
                   php8.1-xmlrpc \
                   php8.1-bcmath \
                   php8.1-opcache \
                   php8.1-mbstring \
                   php-apcu \
                   php-json \
                   php-pear \
                   php-ssh2 \
                   php-redis \
                   php-xdebug \
                   php-sqlite3 \
                   php-imagick \
                   php-memcached \
                   php-codesniffer
RUN apt autoremove -y 
RUN apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Disable php-xdebug:::
RUN echo '' > /etc/php/8.1/mods-available/xdebug.ini

#Uploadprogress:::
RUN pecl install uploadprogress && \
    echo 'extension=uploadprogress.so' > /etc/php/8.1/mods-available/uploadprogress.ini && \
    ln -s /etc/php/8.1/mods-available/uploadprogress.ini /etc/php/8.1/fpm/conf.d/20-uploadprogress.ini

#Redis:::
RUN pecl install redis

#DRUSH:::
RUN wget https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar -q -O drush && \
    chmod +x drush && \
    mv drush /usr/local/bin/drush

#Composer:::
RUN wget https://getcomposer.org/installer -q -O composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer
#Composer-FIX:::
RUN git clone https://github.com/composer/composer.git ~/composer-build && \
    composer install  -o -d ~/composer-build && \
    wget https://raw.githubusercontent.com/politsin/snipets/master/patch/composer.patch -q -O ~/composer-build/composer.patch  && \
    cd ~/composer-build && patch -p1 < composer.patch && \
    php -d phar.readonly=0 bin/compile && \
    rm /usr/local/bin/composer && \
    php composer.phar install && \
    php composer.phar update && \
    mv ~/composer-build/composer.phar /usr/local/bin/composer && \
    rm -rf ~/composer-buil  && \
    chmod +x /usr/local/bin/composer

#NodeJS:::
RUN apt update && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt install -y nodejs && \
    node -v && \
    npm -v && \
    npm install -g npm && \
    npm -v && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean

#Init:::
RUN npm i -g yarn && \
    npm i -g gulp-cli && \
    npm i -g webpack-cli

#GulpPacs:::
RUN cd /var && \
    npm init --yes && \
    npm i gulp && \
    npm i node-sass && \
    npm i gulp-watch && \
    npm i gulp-plumber && \
    npm i gulp-touch-cmd && \
    npm i gulp-sourcemaps && \
    npm i gulp-sass@npm:@selfisekai/gulp-sass && \
    npm i webpack webpack-dev-server

#PhpCS:::
RUN cd ~ && \
    git clone https://git.drupalcode.org/project/coder.git && \
    cd ~/coder && \
    rm ~/coder/coder_sniffer/Drupal/Sniffs/Classes/UseGlobalClassSniff.php && \
    rm ~/coder/tests/Drupal/Classes/UseGlobalClassUnitTest.inc && \
    rm ~/coder/tests/Drupal/Classes/UseGlobalClassUnitTest.inc.fixed && \
    rm ~/coder/tests/Drupal/Classes/UseGlobalClassUnitTest.php && \
    mv ~/coder/coder_sniffer/DrupalPractice /usr/share/php/PHP/CodeSniffer/src/Standards/DrupalPractice && \
    mv ~/coder/coder_sniffer/Drupal /usr/share/php/PHP/CodeSniffer/src/Standards/Drupal && \
    cd ~ && \
    rm -rf /root/coder && \
    phpcs -i && \
    phpcs --config-set colors 1 && \
    phpcs --config-set default_standard Drupal && \
    phpcs --config-show

#COPY script & config:::
COPY config/php/www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY config/php/php.ini /etc/php/8.1/fpm/php.ini
COPY config/php/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY config/php/opcache.ini /etc/php/8.1/mods-available/opcache.ini
COPY config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY config/cron/www-data /var/spool/cron/crontabs/www-data
COPY config/bash/.bash_profile /root/.bash_profile
COPY config/bash/.bashrc /root/.bashrc
COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/start.sh /start.sh

#Fix ownership
RUN chmod 755 /start.sh && \
    mkdir /run/php && \
    chown -R www-data.www-data /run/php && \
    chown www-data.www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data

#Permit ssh login with password (auth key only)
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

# Expose Ports
EXPOSE 22

ENTRYPOINT ["/start.sh"]
