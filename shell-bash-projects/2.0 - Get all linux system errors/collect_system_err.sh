#!/bin/bash

CURR_DATE=$(date +"%Y-%m-%d")
LOG_FILE=/var/log/system-errors-$CURR_DATE.log

if [ ! -d "/var/log" ]; then
    echo "Log directory /var/log does not exist. Exiting..."
    exit 1
fi

# get all error messages from system logs, system files, and system commands and store it to a log file
echo "Logging system errors on $(date)" > $LOG_FILE

dmesg | grep -i "error" >> $LOG_FILE
cat /var/log/syslog | grep -i "error" >> $LOG_FILE
journalctl -xb | grep -i "error" >> $LOG_FILE
find /var/log -type f -exec grep -i "error" {} \; >> $LOG_FILE
dpkg --audit >> $LOG_FILE
apt-get check >> $LOG_FILE
systemctl --failed >> $LOG_FILE

echo "Errors logged on $(date)" >> $LOG_FILE
echo "Error log created at $LOG_FILE. Exiting...."