#!/bin/bash

# Current date for unique backup filenames
DATE=$(date +%F-%H%M%S)

# Backup directory on the host
BACKUP_DIR="/home/akhil/db-backup/mysql/backup"  # Updated to /backup directory

# Log directory and file
LOG_DIR="/home/akhil/db-backup/mysql/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/backup_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Log start time
echo "Backup started at $(date)" >> $LOG_FILE

# Database credentials and details
DB_HOST="mysql"
DB_USER="root"
DB_PASSWORD="root"
DB_NAME="mysql"

BACKUP_FILENAME="$DB_NAME-$DATE.sql"
docker exec mysql /usr/bin/mysqldump -u $DB_USER --password=$DB_PASSWORD  akhil > $BACKUP_DIR/$BACKUP_FILENAME

# Check for errors during backup
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILENAME" >> $LOG_FILE
else
    echo "Backup failed at $(date)" >> $LOG_FILE
fi

# Compress the backup file and log the result
gzip $BACKUP_FILENAME 2>> $LOG_FILE

# Log completion time
echo "Backup completed at $(date)" >> $LOG_FILE



#################################################################

# Find and delete files older than 5 hours (300 minutes)
find $BACKUP_DIR -type f -name "*.sql.gz" -mmin +300 -exec rm -f {} \;

# Optional: Log the deletion
echo "Cleanup completed at $(date)" >> /home/akhil/db-backup/mysql/logs/cleanup_log.txt

