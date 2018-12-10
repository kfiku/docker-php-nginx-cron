#!/usr/bin/env bash

echo "composer version:" && docker run --rm kfiku/docker-php-nginx-cron:build composer --version
echo "php version:"  && docker run --rm kfiku/docker-php-nginx-cron:build php --version
echo "node version:" && docker run --rm kfiku/docker-php-nginx-cron:build node --version
echo "npm version:"  && docker run --rm kfiku/docker-php-nginx-cron:build npm --version

