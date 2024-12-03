#!/bin/bash

# Variables
BACKUP_DIR=/home/akhil/db-backup/postgres/backup
DB_NAME=akhil
DB_USER=root
DB_PASSWORD=root
CONTAINER_NAME=postgres

LOG_DIR="/home/akhil/db-backup/postgres/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/backup_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Ensure that LOG_FILE is a file, not a directory
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi


# Get current date and time for backup file
TIMESTAMP=$(date +"%F_%T")
BACKUP_FILE=$(ls -t $BACKUP_DIR/*.sql | head -n 1)

echo "Restore started at $(date)" >> $LOG_FILE

# Run pg_dump inside the PostgreSQL container
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

# Check for errors during backup
if [ $? -eq 0 ]; then
    echo "backup successful: $BACKUP_FILE" >> $LOG_FILE
else
    echo "Restore failed at $(date)" >> $LOG_FILE
fi

# Log completion time
echo "Restore completed at $(date)" >> $LOG_FILE

