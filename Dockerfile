FROM php:7.1.28-fpm-alpine

LABEL maintainer="Grzegorz Klimek <kfiku.com@gmail.com>"

# TIMEZONE
ENV TZ=Europe/Prague

# DEPENDENCIES
RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    echo http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk update && \
    apk add --no-cache \
        bash \
        curl \
        grep \
        libcrypto1.1 \
        logrotate \
        mysql-client \
        nginx \
        openssh-client \
        rsync \
        wget \
        # PHP DEPT
        freetype \
        geoip \
        gnu-libiconv \
        icu \
        intltool \
        libjpeg-turbo \
        libmcrypt \
        libpng \
        libxml2 \
        openssl \
        tzdata && \
    # PHP BUILD DEPT
    apk add --no-cache --virtual .build-deps \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libxml2-dev \
        openssl-dev \
        zlib-dev && \
    # PHP CONFIGURE EXTS
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    # PHP INSTALL EXTS
    docker-php-ext-install \
        ctype \
        dom \
        gd \
        intl \
        iconv \
        json \
        mbstring \
        mcrypt \
        mysqli \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        phar \
        session \
        soap \
        xml \
        xmlrpc \
        zip && \
    apk del .build-deps && \
    # NGINX DIRS
    mkdir -p /etc/nginx && \
    mkdir -p /var/www/app && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /etc/nginx/ssl/ && \
    rm -Rf /var/www/* && \
    mkdir /var/www/html/ && \
    cp /usr/share/zoneinfo/Europe/Prague /etc/localtime && \
    echo "Europe/Prague" >  /etc/timezone

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php-fpm

# PHP-GEOIP
# RUN pecl install geoip-1.1.1
RUN apk add --no-cache --virtual .build-deps \
        autoconf \
        # gcc \
        g++ \
        make \
        git \
        geoip-dev && \
    mkdir -p /usr/src/php-geoip && \
    git clone https://github.com/Zakay/geoip.git /usr/src/php-geoip && \
    ln -s /usr/bin/php-config7 /usr/bin/php-config && \
    cd /usr/src/php-geoip && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    # curl -SL "https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz" -o GeoIP.dat.gz && \
    # mkdir -p /usr/share/GeoIP && \
    # gzip -d GeoIP.dat.gz && \
    # mv GeoIP.dat /usr/share/GeoIP/ && \
    # echo "extension=geoip.so" > /usr/local/etc/php/conf.d/00_geoip.ini && \
    apk del .build-deps && \
    rm -rf /usr/src/php-geoip && \
    rm /usr/bin/php-config && \
    echo "extension=geoip.so" > /usr/local/etc/php/conf.d/00_geoip.ini


# DUMBINIT
ENV DUMBINIT_VERSION=1.2.2 \
    DUMBINIT_SHA256=37f2c1f0372a45554f1b89924fbb134fc24c3756efaedf11e07f599494e0eff9
RUN curl -fSL https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_amd64 -o /usr/local/bin/dumb-init && \
    echo "$DUMBINIT_SHA256 */usr/local/bin/dumb-init" | sha256sum -c - && \
    chmod +x /usr/local/bin/dumb-init


# COMPOSER
ENV COMPOSER_VERSION=1.7.2
RUN EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    # composer parallel install plugin.
    composer global require hirak/prestissimo


# Add CONF / DBLOCK
COPY scripts/dblock /usr/bin
COPY conf/nginx.conf conf/.inputrc conf/cron.conf conf/application conf/php.ini conf/php.ini conf/php-fpm.conf conf/www.conf \
     scripts/start.sh scripts/init.sh scripts/cron_minutly.sh scripts/logrotate.move.sh /tmp/

RUN mv /tmp/nginx.conf /etc/nginx/nginx.conf && \
    mv /tmp/cron.conf /etc/cron.conf && \
    mv /tmp/application /etc/logrotate.d/application && \
    mv /tmp/start.sh /start.sh && \
    mv /tmp/init.sh /init.sh && \
    mv /tmp/cron_minutly.sh /etc/cron_minutly.sh && \
    mv /tmp/logrotate.move.sh /etc/logrotate.move.sh && \
    mv /tmp/.inputrc /root/.inputrc && \
    mv /tmp/php.ini      /usr/local/etc/php/php.ini && \
    mv /tmp/php-fpm.conf /usr/local/etc/php-fpm.conf && \
    mv /tmp/www.conf     /usr/local/etc/php-fpm.d/www.conf && \
    rm /usr/local/etc/php-fpm.d/zz-docker.conf && \
    chmod +x /start.sh /init.sh /etc/logrotate.move.sh /etc/cron_minutly.sh

COPY conf/GeoIP.dat /usr/share/GeoIP/GeoIP.dat

WORKDIR /application

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/start.sh"]
