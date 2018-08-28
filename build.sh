#!/usr/bin/env bash

docker build -t kfiku/docker-php-nginx-cron .
docker build -t kfiku/docker-php-nginx-cron:build build
