#!/bin/bash

update-ca-certificates

if [[ -z $CRON_USER ]]; then
    CRON_USER="root"
fi

echo "Starting cron demon ad user $CRON_USER"
crontab -u $CRON_USER /etc/cron.conf
crond

echo 'Starting php-fpm'
php-fpm -D

echo 'Starting nginx'

CONTAINER_IP=$(awk 'END{print $1}' /etc/hosts)

echo "

Access URLs:
-----------------------------------
 PROD: http://$CONTAINER_IP
  DEV: http://$CONTAINER_IP/app_dev.php
-----------------------------------

"

nginx -g 'daemon off;'
