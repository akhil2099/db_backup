#!/bin/bash

# Current date for unique backup filenames
DATE=$(date +%F-%H%M%S)

# Backup directory on the host
BACKUP_DIR="/home/akhil/db-backup/mssql/backup"  # Updated to /backup directory for MSSQL

# Log directory and file
LOG_DIR="/home/akhil/db-backup/mssql/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/backup_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Log start time
echo "Backup started at $(date)" >> $LOG_FILE

# Database credentials and details
DB_HOST="mssql"
DB_USER="SA"
DB_PASSWORD="Asd1234."
DB_NAME="akhil"  # Replace with your actual database name

BACKUP_FILENAME="$DB_NAME-$DATE.bak"

# Perform the backup using SQLCMD (MSSQL) inside the container
docker exec -t mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U $DB_USER -P $DB_PASSWORD -C -Q "BACKUP DATABASE [$DB_NAME] TO DISK='/var/opt/mssql/data/$BACKUP_FILENAME'"

# Check for errors during backup
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILENAME" >> $LOG_FILE
else
    echo "Backup failed at $(date)" >> $LOG_FILE
fi

# Move the backup to the backup directory on the host
docker cp mssql:/var/opt/mssql/data/$BACKUP_FILENAME $BACKUP_DIR/$BACKUP_FILENAME

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "Backup file moved successfully to $BACKUP_DIR/$BACKUP_FILENAME" >> $LOG_FILE
else
    echo "Failed to move backup file to host directory" >> $LOG_FILE
fi

# Optionally, remove the backup file inside the container
docker exec mssql rm /var/opt/mssql/data/$BACKUP_FILENAME

# Log completion time
echo "Backup completed at $(date)" >> $LOG_FILE



