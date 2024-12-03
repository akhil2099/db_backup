#!/bin/bash

# Current date in YYYY-MM-DD-HHMMSS format for unique backup filenames
DATE=$(date +%F-%H%M%S)

# Backup directory on the host
BACKUP_DIR="/home/akhil/db-backup/mongodb/backup"  # Update to the desired backup directory for MongoDB

# Log directory and file
LOG_DIR="/home/akhil/db-backup/mongodb/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/backup_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Ensure that LOG_FILE is a file, not a directory
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Log start time
echo "Backup started at $(date)" >> $LOG_FILE

# Database credentials and details
CONTAINER_NAME="mongodb"  
DB_USER="admin"           
DB_PASSWORD="password"    
DB_NAME="akhil"           
AUTH_DB="admin"           


BACKUP_FILENAME="$BACKUP_DIR/$DB_NAME-$DATE.dump"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Perform the backup and stream to a file
docker exec -i $CONTAINER_NAME /usr/bin/mongodump \
    --username $DB_USER \
    --password $DB_PASSWORD \
    --authenticationDatabase $AUTH_DB \
    --db $DB_NAME \
    --archive > $BACKUP_FILENAME

# Check for errors during backup
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILENAME" >> $LOG_FILE
else
    echo "Backup failed at $(date)" >> $LOG_FILE
fi

# Log completion time
echo "Backup completed at $(date)" >> $LOG_FILE

