# lamp_base - Agent Instructions

Welcome to the `lamp_base` codebase. This document serves as a critical overview of the container's architecture and purpose.

## Project Tracking
Development effort across the workspace (including `GTCGDB` and `godzillatcgdb`) is tracked in this public GitHub Project:
https://github.com/users/nfraker/projects/1

**Always read this document before attempting to modify the Docker configuration.**

## Tech Stack
*   **OS/Base**: `php:8.4-apache` (Debian Bookworm)
*   **Database**: `mariadb-server`
*   **PHP Version**: 8.4.x

## Architectural Context
This repository was created to construct a base image containing all necessary packages to run Laravel (PHP, MySQL/MariaDB, etc.). The goal is to keep downstream Dockerfiles (like in the `GTCGDB` project) simple, where they are only responsible for copying the codebase, compiling, running migrations, etc.

### 1. MariaDB vs MySQL
Because the base image is `php:8.4-apache` (which uses Debian Bookworm), the standard MySQL Server package has been replaced by `mariadb-server`. MariaDB functions as a drop-in replacement for MySQL. 

### 2. Startup Script (`startup.sh`)
The container's entrypoint is `/startup.sh`. This script is responsible for two primary actions:
1.  **Database Initialization**: It checks the `START_MYSQL` environment variable. If true or unset, it touches the mysql lib files to prevent permission errors and starts the `mariadb` service.
2.  **Apache Execution**: It executes `apache2ctl -D FOREGROUND` to keep the container running and serve web requests.

If a downstream application provides an external database connection via environment variables (e.g., pointing to an RDS instance or an external Docker network), the downstream Dockerfile should define `ENV START_MYSQL=false` to save memory and skip initializing the redundant local database.

### 3. Document Root Configuration
Laravel applications serve their public assets from the `/public` directory, not the standard `/html` directory. The `lamp_base` Dockerfile dynamically modifies Apache's default configuration to point the `DocumentRoot` to whatever path is defined in the `APACHE_DOCUMENT_ROOT` environment variable. 

### 4. GitHub Actions Tagging Logic
The `.github/workflows/docker-publish.yml` action is configured to build the Docker image when pushed to the `main` branch. It utilizes the following dynamic tagging logic:
- `ikaruwa/lamp_base:latest` (The latest build)
- `ikaruwa/lamp_base:laravel-13` (The latest build targeting Laravel 13 compatibility)
- `ikaruwa/lamp_base:laravel-13.5.0` (The specific pinned version of the framework it was built to support)
