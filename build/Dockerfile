FROM kfiku/docker-php-nginx-cron

RUN apk update

RUN apk add --no-cache \
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

COPY php.ini /usr/local/etc/php/php.ini
