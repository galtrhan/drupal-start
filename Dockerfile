FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    libpq-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    icu-dev \
    oniguruma-dev \
    pcre-dev

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_pgsql \
    gd \
    zip \
    bcmath \
    intl \
    opcache

# Install APCu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PHP configuration
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Configure Git safe directory
RUN git config --global --add safe.directory /var/www/html

WORKDIR /var/www/html

CMD ["php-fpm"]
