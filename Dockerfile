FROM php:8.4-apache-bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite and SSL
RUN a2enmod rewrite ssl

# Add a self-signed SSL certificate (development only)
RUN mkdir /etc/apache2/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configure SSL in Apache
RUN echo "\
<VirtualHost *:443>\n\
    DocumentRoot /var/www/html\n\
    SSLEngine on\n\
    SSLCertificateFile /etc/apache2/ssl/apache.crt\n\
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key\n\
</VirtualHost>" > /etc/apache2/sites-available/default-ssl.conf && \
    a2ensite default-ssl

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

EXPOSE 80 443
