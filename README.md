[![Publish Docker Image](https://github.com/nfraker/lamp_base/actions/workflows/docker-publish.yml/badge.svg?branch=main)](https://github.com/nfraker/lamp_base/actions/workflows/docker-publish.yml)
# lamp_base - A Modern LAMP Docker Base Image
This is a generalized, all-in-one Docker image designed to support modern PHP applications (like Laravel 13+) that require a classic LAMP (Linux, Apache, MariaDB, PHP) stack.

It serves as the base layer for projects like [GTCGDB](https://github.com/ikaruwa/gtcgdb), abstracting away system dependencies, PHP extension compilation, and database initialization into a single reusable container.

## Included Components
*   **Base Image**: `php:8.4-apache`
*   **Database**: `mariadb-server` (Debian's default MySQL equivalent)
*   **PHP Extensions**: `pdo_mysql`, `gd`, `zip`, `bcmath`
*   **Tools**: `composer` (latest), `git`, `unzip`

## Features

### Dynamic Document Root
By default, Apache serves files from `/var/www/html`. You can override this dynamically in your downstream Dockerfile by setting the `APACHE_DOCUMENT_ROOT` environment variable:

```dockerfile
ENV APACHE_DOCUMENT_ROOT=/var/www/public
```

### Optional MariaDB Startup
By default, the container starts MariaDB automatically. If your application relies on an external database (e.g., hosted outside the container or via another Docker Compose service), you can disable the local database startup by setting `START_MYSQL` to `false`:

```dockerfile
ENV START_MYSQL=false
```

## Building & Usage
To use this image as a base layer for your application, reference it in your project's Dockerfile:

```dockerfile
FROM ikaruwa/lamp_base:latest

# Set custom Apache root
ENV APACHE_DOCUMENT_ROOT=/var/www/public

# Disable local DB if using an external one
ENV START_MYSQL=false

COPY . /var/www
WORKDIR /var/www
RUN composer install
```

## CI/CD Pipeline
This repository includes a GitHub Action (`.github/workflows/docker-publish.yml`) that automatically builds and pushes the image to Docker Hub at `ikaruwa/lamp_base:latest` whenever changes are pushed to the `main` branch.
