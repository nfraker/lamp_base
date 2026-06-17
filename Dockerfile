FROM php:8.4-apache

LABEL name="lamp_base"
LABEL version="laravel-13.5.0"
LABEL release="0"
LABEL architecture="x86_64"
LABEL vendor="Nick Fraker <nickdontspam@gmail.com>"
LABEL vcs-type="git"
LABEL vcs-url="https://github.com/nfraker/lamp_base"
LABEL authoritative-source-url="https://hub.docker.com/r/ikaruwa/lamp_base"
LABEL distribution-scope="public"

# Install system dependencies, mariadb (mysql alternative for debian), and PHP extensions
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mariadb-server \
    mariadb-client \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql gd zip bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Setup DocumentRoot env var and update apache config
ENV APACHE_DOCUMENT_ROOT=/var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}/!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Setup startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Forward Apache logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log

# Initialize MariaDB
RUN service mariadb start && \
    mysql -u root -e "CREATE USER IF NOT EXISTS 'debian-sys-maint'@'%' IDENTIFIED BY 'rEnmwp1CsUrNWI2X'; GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'%'; FLUSH PRIVILEGES;"

EXPOSE 80 443
CMD ["/startup.sh"]
