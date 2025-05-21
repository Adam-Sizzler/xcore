#!/usr/bin/env bash

LOG_FILE="/opt/xcore/cron_jobs.log"
BACKUP_DIR="/opt/xcore/backup"
DAY_TO_KEEP=6

echo "$(date): Starting backup rotation" >> "$LOG_FILE"
mkdir -p "$BACKUP_DIR" || { echo "$(date): Failed to create $BACKUP_DIR" >> "$LOG_FILE"; exit 1; }

find "$BACKUP_DIR" -type f -name "backup_*.7z" -mtime "+$DAY_TO_KEEP" -exec rm -v -f {} \; | while read -r line; do
  echo "$(date): Deleted file: $line" >> "$LOG_FILE"
done

echo "$(date): Completed backup rotation" >> "$LOG_FILE"
echo >> "$LOG_FILE"
