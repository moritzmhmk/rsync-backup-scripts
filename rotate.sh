#!/bin/sh

MAX_HOURLY_BACKUPS=12
MAX_DAILY_BACKUPS=30

HOURLY_BACKUPS=(????-??-??_??.??.??)
DAILY_BACKUPS=(????-??-??)


if [ ${#HOURLY_BACKUPS[@]} -gt $MAX_HOURLY_BACKUPS ]; then
    old_HOURLY_BACKUPS=${HOURLY_BACKUPS[@]::${#HOURLY_BACKUPS[@]}-$MAX_HOURLY_BACKUPS}
    echo "removing old hourly backups: "$old_HOURLY_BACKUPS
    rm -r $old_HOURLY_BACKUPS
fi

if [ ${#DAILY_BACKUPS[@]} -gt $MAX_DAILY_BACKUPS ]; then
    old_DAILY_BACKUPS=${DAILY_BACKUPS[@]::${#DAILY_BACKUPS[@]}-$MAX_DAILY_BACKUPS}
    echo "removing old daily backups: "$old_DAILY_BACKUPS
    rm -r $old_DAILY_BACKUPS
fi
