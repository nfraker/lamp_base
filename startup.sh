#!/bin/bash

# Start MySQL/MariaDB if not explicitly disabled
if [ "${START_MYSQL:-true}" = "true" ]; then
    echo "Starting MariaDB..."
    find /var/lib/mysql -type f -exec touch {} \;
    service mariadb start || service mysql start
else
    echo "START_MYSQL is set to false. Skipping MariaDB startup."
fi

# Execute Apache in the foreground
echo "Starting Apache2..."
exec apache2ctl -D FOREGROUND
