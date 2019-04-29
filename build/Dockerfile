FROM kfiku/docker-php-nginx-cron

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    echo http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
  apk update && \
  apk add --no-cache \
  alpine-sdk \
  autoconf \
  automake \
  build-base \
  fontconfig \
  g++ \
  giflib-dev \
  gifsicle \
  git \
  gpgme \
  gzip \
  jpeg-dev \
  libjpeg-turbo \
  libjpeg-turbo-dev \
  libpng \
  libpng-dev \
  libwebp \
  libwebp-dev \
  mysql-client \
  nasm \
  nodejs \
  npm \
  python \
  redis \
  zlib \
  zlib-dev \
  make

RUN pecl install xdebug-2.5.0 \
  && docker-php-ext-enable xdebug

# PHANTOM
# RUN curl -Ls https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz | tar xz -C /

RUN npm install -g npm grunt-cli -q --cache-min 999999

ENV PHP_INI_DIR=/usr/local/etc/php \
    php_conf=$PHP_INI_DIR/php.ini \
    fpm_conf=/usr/local/etc/php-fpm.conf

# SET PHP MEM LIMIT TO 2GB
RUN ls $PHP_INI_DIR/conf.d && \
    sed -i -e "s/memory_limit\s*=\s*512M/memory_limit = 5G/g" $php_conf && \
    cat $php_conf | grep memory_limit

ENV PHPSTAN_VERSION=0.11.5
RUN curl -sSL https://github.com/phpstan/phpstan/releases/download/${PHPSTAN_VERSION}/phpstan.phar -o phpstan.phar && \
    # Install it as an executable:
    chmod a+x phpstan.phar && \
    mv phpstan.phar /usr/bin/phpstan

ENV PHPCS_VERSION=3.4.1
RUN curl -sSL https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${PHPCS_VERSION}/phpcs.phar -o phpcs.phar && \
    # Install it as an executable:
    chmod a+x phpcs.phar && \
    mv phpcs.phar /usr/bin/phpcs
