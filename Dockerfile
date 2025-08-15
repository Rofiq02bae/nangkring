# Dockerfile untuk Laravel 12 + Vite + Jenkins CI/CD Project
FROM php:8.2-fpm

LABEL Name=nangkring Version=1.0.0
LABEL Description="Laravel 12 with Vite and Jenkins CI/CD"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring bcmath gd intl curl zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Install Node.js 20+
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Set working directory
WORKDIR /var/www

# Copy Laravel project
COPY laravel-jenkins-app/src/ /var/www

# Set permissions
RUN chown -R www-data:www-data /var/www

EXPOSE 8000
CMD ["php-fpm"]
CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]
