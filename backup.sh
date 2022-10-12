#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source target"
    exit 1
fi

SOURCE=$1
TARGET=$2

echo "Starting backup from $SOURCE to $TARGET using rsync."
rsync --archive --human-readable --progress --link-dest "../current" "$SOURCE/" "$TARGET/incomplete"
rsync_exit_code=$?

if [ "$rsync_exit_code" -ne "0" ] && [ "$rsync_exit_code" -ne "23" ] && [ "$rsync_exit_code" -ne "24" ]; then
    echo "Backup incomplete - rsync exited with code $rsync_exit_code"
    exit $rsync_exit_code
fi

echo "Transfer completed. Now moving 'incomplete' to 'current'."
rm -r "$TARGET/current"
mv "$TARGET/incomplete" "$TARGET/current"

# Create hourly, daily and monthly backup copies as required.

HOURLY_NAME="$(date +%Y-%m-%d_%Hh)" # 2022-10-11_16h
DAILY_NAME="$(date +%Y-%m-%d)"      # 2022-10-11
MONTHLY_NAME="$(date +%Y-%m)"       # 2022-10

if [ ! -e "$TARGET/$HOURLY_NAME" ]; then
    echo "Creating hourly backup copy '$HOURLY_NAME'."
    cp -al "$TARGET/current" "$TARGET/$HOURLY_NAME"
fi

if [ ! -e "$TARGET/$DAILY_NAME" ]; then
    echo "Creating daily backup copy '$DAILY_NAME'."
    cp -al "$TARGET/current" "$TARGET/$DAILY_NAME"
fi

if [ ! -e "$TARGET/$MONTHLY_NAME" ]; then
    echo "Creating monthly backup copy '$MONTHLY_NAME'."
    cp -al "$TARGET/current" "$TARGET/$MONTHLY_NAME"
fi

# Delete old hourly and daily backups beyond defined limit.

MAX_HOURLY_BACKUPS=12
MAX_DAILY_BACKUPS=30

HOURLY_BACKUPS=("$TARGET"/????-??-??_??h)
DAILY_BACKUPS=("$TARGET"/????-??-??)

if [ ${#HOURLY_BACKUPS[@]} -gt $MAX_HOURLY_BACKUPS ]; then
    old_HOURLY_BACKUPS=("${HOURLY_BACKUPS[@]::${#HOURLY_BACKUPS[@]}-$MAX_HOURLY_BACKUPS}")
    echo "Removing ${#old_HOURLY_BACKUPS[@]} old hourly backups: " "${old_HOURLY_BACKUPS[@]}"
    rm -r "${old_HOURLY_BACKUPS[@]}"
fi

if [ ${#DAILY_BACKUPS[@]} -gt $MAX_DAILY_BACKUPS ]; then
    old_DAILY_BACKUPS=("${DAILY_BACKUPS[@]::${#DAILY_BACKUPS[@]}-$MAX_DAILY_BACKUPS}")
    echo "Removing ${#old_DAILY_BACKUPS[@]} old daily backups: " "${old_DAILY_BACKUPS[@]}"
    rm -r "${old_DAILY_BACKUPS[@]}"
fi

echo "Done."
