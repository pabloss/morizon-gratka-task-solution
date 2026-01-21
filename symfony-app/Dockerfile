FROM php:8.2-cli

# Instalacja zależności systemowych i bibliotek
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalacja rozszerzeń PHP
RUN docker-php-ext-install intl pdo pdo_pgsql

# Instalacja Composera
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalacja Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

WORKDIR /app

# UWAGA: Usunęliśmy 'composer create-project'.
# Zrobimy to ręcznie po podpięciu wolumenu.

EXPOSE 8000

# Domyślna komenda startowa
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]