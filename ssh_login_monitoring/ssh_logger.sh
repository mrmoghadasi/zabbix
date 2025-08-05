#!/bin/bash

if [ "$PAM_TYPE" != "open_session" ]; then
    exit 0
fi

LOGFILE="/var/log/zabbix-ssh-logins.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOST=$(hostname)
USER="$PAM_USER"
IP="$PAM_RHOST"
SERVICE="$PAM_SERVICE"
TTY="$PAM_TTY"

echo "User: $USER | IP: $IP | Time: $DATE | Host: $HOST | Service: $SERVICE | TTY: $TTY" >> "$LOGFILE"
