# Stage 1: Build Drupal
FROM debian:buster-slim AS build

RUN apt-get update && apt-get install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update && apt-get install -y \
    unzip \
    nginx \
    mariadb-client \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libzip-dev

WORKDIR /var/www/html

# Copy your Drupal code to the container
COPY . /var/www/html

# Install dependencies and build Drupal
RUN composer install

# Stage 2: Create the final image
FROM php:7.4-fpm

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip

# Copy the built Drupal from the previous stage
COPY --from=build /var/www/html /var/www/html

# Configure Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the port Nginx will listen on
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm
