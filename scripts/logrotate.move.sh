#!/usr/bin/env bash

# application
backupDir="/application/app/logs/backup"
if [[ ! -d $backupDir ]]; then
    mkdir -p $backupDir
fi

for f in $(find /application/app/logs/ -mtime +1 | grep -v "backup" | grep ".log-")
do
    if [[ -e $f ]]; then
        echo "moving $f to $backupDir"
        mv $f $backupDir
    fi
done

nginx -s reload
