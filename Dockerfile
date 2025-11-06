# Stage 1: Build with Composer
FROM composer:2 AS builder

WORKDIR /app

# Copy only composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Install dependencies (ignore platform requirements for extensions)
RUN composer install --no-dev --ignore-platform-req=ext-* \
  --optimize-autoloader --no-interaction --no-progress

# Copy the full Drupal codebase
COPY web /app

# Stage 2: Runtime
FROM drupal:10

WORKDIR /var/www/html

# Copy built app from builder stage
RUN rm -rf /opt/drupal/*
COPY --from=builder /app/ /opt/drupal/

# Fix file permissions
RUN chown -R www-data:www-data /var/www/html