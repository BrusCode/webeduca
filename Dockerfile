# Dockerfile para Academy LMS
FROM php:8.1-apache

# Instalar extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo pdo_mysql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar código da aplicação
COPY . /var/www/html/

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/uploads \
    && chmod -R 777 /var/www/html/backups \
    && chmod 666 /var/www/html/application/config/database.php \
    && chmod 666 /var/www/html/application/config/routes.php

# Configurar Apache para permitir .htaccess
RUN echo '<Directory /var/www/html>' > /etc/apache2/conf-available/academy.conf \
    && echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/academy.conf \
    && echo '    AllowOverride All' >> /etc/apache2/conf-available/academy.conf \
    && echo '    Require all granted' >> /etc/apache2/conf-available/academy.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/academy.conf \
    && a2enconf academy

# Expor porta 80
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]

