FROM php:7.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
	  libzip-dev \
    zip \
    unzip \
	  nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
	intl \
	pdo \
	pdo_mysql \
	mbstring \
	exif \
	pcntl \
	bcmath \
	gd

# Install PHP intl extension
RUN docker-php-ext-configure intl \
	&& docker-php-ext-install intl

# Install PHP zip extension
RUN docker-php-ext-configure zip \
	&& docker-php-ext-install zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/

COPY . .
COPY ./nginx/php.conf /etc/nginx/conf.d/php.conf

RUN composer install
RUN php artisan migrate
RUN php artisan view:clear
RUN php artisan cache:clear
#RUN echo "memory_limit = -1" > $PHP_INI_DIR/conf.d/memory-limit.ini
#RUN rm $PHP_INI_DIR/conf.d/memory-limit.ini
RUN gpasswd -a "root" www-data
RUN chown -R "root":www-data /var/www
RUN find /var/www -type f -exec chmod 0660 {} \;
RUN find /var/www -type d -exec chmod 2770 {} \;
RUN chmod +x ./start.sh

CMD ["./start.sh"]
