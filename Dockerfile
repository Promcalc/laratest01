FROM php:8.3-fpm-alpine

ENV TZ=Europe/Moscow

RUN apk update && \
    apk add --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    linux-headers \
    autoconf \
    automake \
    build-base \
    gcc \
    make \
    libc-dev \
    wget \
    unzip \
    bzip2 \
    tar \
    tzdata \
    libmcrypt-dev \
    pcre-dev \
    libxml2-dev \
    libxslt-dev \
    libpq-dev \
    libzip-dev \
    bzip2-dev \
    fontconfig \
    libxrender \
    libxext \
    zlib-dev \
    libpng-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libmemcached-dev \
    && rm -rf /var/cache/apk/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-freetype \
    && docker-php-ext-install bcmath bz2 gd pdo_mysql pdo_pgsql soap xml xsl exif opcache sockets zip \
    && pecl install mcrypt-1.0.7 \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mcrypt \
    && apk add musl-locales musl-locales-lang alpine-conf \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/bin --filename=composer --quiet \
    && php -r "unlink('composer-setup.php');"

# RUN pecl install memcached-3.1.5
# RUN docker-php-ext-enable memcached

# Установка локалей через setup-i18n - не работает
# RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
#    && setup-i18n

ADD ./php.example.ini /usr/local/etc/php/php.ini

ENV LANG en_US.UTF-8
ENV LANGUAGE en_EN:en
ENV LC_LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY . /var/www

RUN cd /var/www \
    && composer install --no-dev

WORKDIR /var/www
