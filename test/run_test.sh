#!/usr/bin/env bash

rm -r tmp
mkdir tmp
cd tmp || exit
mkdir source target
# create empty monthly, daily and hourly backups in 1970 to test the deletion of old backups
mkdir target/1970-{01..12}
mkdir target/1970-12-{01..31}
mkdir target/1970-12-30_{00..23}h
mkdir target/1970-12-31_{00..06}h

# create a file to backup
TEST_FILE="hello.txt"
echo "Hello World!" >source/"$TEST_FILE"

# run backup
../../backup.sh source target

DAILY_NAME="$(date +%Y-%m-%d)" # 2022-10-11
MONTHLY_NAME="$(date +%Y-%m)"  # 2022-10

current_inode=$(ls -i target/current/$TEST_FILE | awk '{print $1}')
daily_inode=$(ls -i target/${DAILY_NAME}/$TEST_FILE | awk '{print $1}')
monthly_inode=$(ls -i target/${MONTHLY_NAME}/$TEST_FILE | awk '{print $1}')

if [ "$current_inode" -eq "$daily_inode" ] && [ "$current_inode" -eq "$monthly_inode" ]; then
    echo "Hardlink created successfully - inodes of current, daily and monthly version of $TEST_FILE are identical."
else
    echo "FAILED: Hardlink NOT created successfully - inodes of current ($current_inode), daily ($daily_inode) and monthly ($monthly_inode) version of $TEST_FILE are NOT identical."
    exit 1
fi

if [ ! -d target/1970-12-30_19h ]; then
    echo "Hourly Backup 1970-12-30_19h was removed as expected."
else
    echo "FAILED: Hourly Backup 1970-12-30_19h was NOT removed as expected."
    exit 1
fi

if [ -d target/1970-12-30_20h ]; then
    echo "Hourly Backup 1970-12-30_20h was retained as expected."
else
    echo "FAILED: Hourly Backup 1970-12-30_20h was NOT retained as expected."
    exit 1
fi

if [ ! -d target/1970-12-02 ]; then
    echo "Daily Backup 1970-12-02 was removed as expected."
else
    echo "FAILED: Daily Backup 1970-12-02 was NOT removed as expected."
    exit 1
fi

if [ -d target/1970-12-03 ]; then
    echo "Daily Backup 1970-12-03 was retained as expected."
else
    echo "FAILED: Daily Backup 1970-12-03 was NOT retained as expected."
    exit 1
fi
