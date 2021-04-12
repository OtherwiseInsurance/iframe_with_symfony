FROM php:8.0 AS builder
WORKDIR /var/www/
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git libzip-dev zip unzip && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install zip
RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony/bin/symfony /usr/local/bin/symfony
COPY composer.json composer.lock /var/www/
RUN composer install


FROM builder AS development
WORKDIR /var/www/
CMD composer install ; symfony server:start --no-tls
EXPOSE 8000
