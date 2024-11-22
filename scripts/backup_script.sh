#!/bin/bash

# Current date in YYYY-MM-DD-HHMMSS format for unique backup filenames
DATE=$(date +%F-%H%M%S)

# Backup directory on the host
BACKUP_DIR="./backup"  # Updated to /backup directory

# Log directory and file
LOG_DIR="/home/akhil/db-backup/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/backup_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Log start time
echo "Backup started at $(date)" >> $LOG_FILE

# Database credentials and details
DB_HOST="my-mysql"
DB_USER="username"
DB_PASSWORD="password"
DB_NAME="database_name"
NETWORK="my-app-network"

# Docker image version of MySQL
MYSQL_IMAGE="mysql:8.0"

# Backup filename
BACKUP_FILENAME="$BACKUP_DIR/$DB_NAME-$DATE.sql"

# Run mysqldump within a new Docker container and log the result
docker run --rm --network $NETWORK $MYSQL_IMAGE \
  /usr/bin/mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILENAME 2>> $LOG_FILE

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
echo "Cleanup completed at $(date)" >> /home/akhil/db-backup/logs/cleanup_log.txt

