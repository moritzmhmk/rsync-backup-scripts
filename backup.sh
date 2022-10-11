#!/bin/sh
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source target"
    exit 1
fi

SOURCE=$1
TARGET=$2

rsync --archive --human-readable --progress --link-dest "$TARGET/current" "$SOURCE/" "$TARGET/incomplete"
rsync_exit_code=$?

if [ "$rsync_exit_code" -eq "0" ] || [ "$rsync_exit_code" -eq "23" ] || [ "$rsync_exit_code" -eq "24" ] 
then
    HOURLY_NAME="$(date +%Y-%m-%d_%Hh)" # 2022-10-11_16h
    DAILY_NAME="$(date +%Y-%m-%d)" # 2022-10-11
    MONTHLY_NAME="$(date +%Y-%m)" # 2022-10

    # delete existing backup for the current hour
    if [ -e "$TARGET/$HOURLY_NAME" ]; then
        echo "Deleting existing hourly backup."
        rm -r "$TARGET/$HOURLY_NAME"
    fi
    # rename "incomplete" backup (that is now complete)
    mv "$TARGET/incomplete" "$TARGET/$HOURLY_NAME"
    # and create new "current" symlink
    rm -f "$TARGET/current"
    ln -s "$TARGET/$HOURLY_NAME" "$TARGET/current"

    # create daily backup copy
    if [ ! -e "$TARGET/$DAILY_NAME" ]; then
        cp -al "$TARGET/$HOURLY_NAME" "$TARGET/$DAILY_NAME"
    fi

    # create monthly backup copy
    if [ ! -e "$TARGET/$MONTHLY_NAME" ]; then
        cp -al "$TARGET/$HOURLY_NAME" "$TARGET/$MONTHLY_NAME"
    fi
else
    echo "Backup incomplete - rsync exited with code $rsync_exit_code"
fi
