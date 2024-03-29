FROM php:8.2-cli
RUN apt-get update \
    &&  apt-get install -y --no-install-recommends \
    locales apt-utils git libicu-dev g++ libpng-dev libxml2-dev libzip-dev libonig-dev libxslt-dev unzip libpq-dev nodejs npm wget nano \
    apt-transport-https lsb-release ca-certificates

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen  \
    &&  echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
    &&  locale-gen

RUN curl -sS https://getcomposer.org/installer | php -- \
    &&  mv composer.phar /usr/local/bin/composer

RUN curl -sS https://get.symfony.com/cli/installer | bash \
    &&  mv /root/.symfony5/bin/symfony /usr/local/bin

RUN docker-php-ext-configure \
    intl \
    &&  docker-php-ext-install \
    pdo pdo_mysql pdo_pgsql opcache intl zip calendar dom mbstring gd xsl

RUN pecl install apcu && docker-php-ext-enable apcu

RUN npm install --global yarn

RUN pecl install xdebug apcu \
    && docker-php-ext-enable xdebug apcu
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN git config --global user.email "legoffchristophealexandre@gmail.com" \
    &&  git config --global user.name "legoffchristophealexandre@gmail.com"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY app/  /var/www/html

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD tail -f /dev/null

WORKDIR /var/www/html

ENTRYPOINT [ "docker-entrypoint.sh" ]