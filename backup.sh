#!/bin/sh
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source target"
    exit 1
fi

SOURCE=$1
TARGET=$2

rsync --archive --human-readable --progress --link-dest "$TARGET/current" "$SOURCE/" "$TARGET/incomplete"
rsync_exit_code=$?

if [ "$rsync_exit_code" -eq "0" ] || [ "$rsync_exit_code" -eq "23" ] || [ "$rsync_exit_code" -eq "24" ]; then
    # delete existing current backup and rename "incomplete" backup (that is now complete)
    rm -r "$TARGET/current"
    mv "$TARGET/incomplete" "$TARGET/current"

    HOURLY_NAME="$(date +%Y-%m-%d_%Hh)" # 2022-10-11_16h
    DAILY_NAME="$(date +%Y-%m-%d)"      # 2022-10-11
    MONTHLY_NAME="$(date +%Y-%m)"       # 2022-10

    # create hourly backup copy
    if [ ! -e "$TARGET/$HOURLY_NAME" ]; then
        cp -al "$TARGET/current" "$TARGET/$HOURLY_NAME"
    fi

    # create daily backup copy
    if [ ! -e "$TARGET/$DAILY_NAME" ]; then
        cp -al "$TARGET/current" "$TARGET/$DAILY_NAME"
    fi

    # create monthly backup copy
    if [ ! -e "$TARGET/$MONTHLY_NAME" ]; then
        cp -al "$TARGET/current" "$TARGET/$MONTHLY_NAME"
    fi
else
    echo "Backup incomplete - rsync exited with code $rsync_exit_code"
fi
