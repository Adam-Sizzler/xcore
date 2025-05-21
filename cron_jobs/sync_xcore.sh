#!/usr/bin/env bash

LOG_FILE="/opt/xcore/cron_jobs.log"
echo "$(date): Starting xcore sync" >> "$LOG_FILE"

chmod +x /opt/xcore/repo/bin/xcore
rsync -av --exclude='.env' "/opt/xcore/repo/bin/" "/usr/local/xcore/" >> "$LOG_FILE" 2>&1

echo "$(date): Completed xcore sync" >> "$LOG_FILE"
echo >> "$LOG_FILE"
