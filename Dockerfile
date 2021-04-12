FROM php:8.0 AS builder
WORKDIR /var/www/html/
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
COPY composer.json composer.lock /var/www/html/
RUN composer install --no-dev --optimize-autoloader


FROM builder AS development
ENV \
    APP_ENV=dev \
    APP_DEBUG=1 \
    OTHERWISE_URL=http://localhost:8000
WORKDIR /var/www/html
CMD composer install ; symfony server:start --no-tls
EXPOSE 8000


FROM php:8.0-apache AS production
ENV \
    APACHE_DOCUMENT_ROOT=/var/www/html/public \
    APP_ENV=prod \
    APP_DEBUG=0
COPY ./apache/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
WORKDIR /var/www/html/
COPY . .
COPY --from=builder /var/www/html/vendor .
RUN chown -R www-data:www-data /var/www/html
