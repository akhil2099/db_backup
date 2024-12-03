#!/bin/bash

# Define variables
BACKUP_DIR="/home/akhil/db-backup/mongodb/backup"  # Directory containing backups on the host
CONTAINER_NAME="mongodb"                           # MongoDB container name
DB_NAME="akhil"                                    # Database name to restore
LOG_DIR="/home/akhil/db-backup/mongodb/logs"       # Directory for logs
LOG_FILE="$LOG_DIR/restore_log.txt"               # Log file location
BACKUP_CONTAINER_DIR="/tmp"                        # Temporary directory inside the container

# MongoDB credentials
DB_USER="admin"
DB_PASSWORD="password"
AUTH_DB="admin"

# Create log directory and file if they don't exist
mkdir -p $LOG_DIR
touch $LOG_FILE

# Find the latest .dump backup file in the backup directory
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.dump | head -n 1)

# Check if a backup file was found
if [ -z "$LATEST_BACKUP" ]; then
    echo "$(date): No backup files found in the directory." >> $LOG_FILE
    exit 1
fi

echo "$(date): Latest backup file: $LATEST_BACKUP" >> $LOG_FILE

# Copy the latest backup file to the container
docker cp "$LATEST_BACKUP" "$CONTAINER_NAME:$BACKUP_CONTAINER_DIR/backup.dump"

# Restore the database using mongorestore inside the container
docker exec -i "$CONTAINER_NAME" /usr/bin/mongorestore \
  --username "$DB_USER" \
  --password "$DB_PASSWORD" \
  --authenticationDatabase "$AUTH_DB" \
  --nsInclude="$DB_NAME.*" \
  --archive="$BACKUP_CONTAINER_DIR/backup.dump" \
  --drop

# Check if the restore was successful
if [ $? -eq 0 ]; then
    echo "$(date): Database restore completed successfully from $LATEST_BACKUP." >> $LOG_FILE
else
    echo "$(date): Database restore failed." >> $LOG_FILE
fi

# Optionally, remove the backup file from the container
docker exec "$CONTAINER_NAME" rm -f "$BACKUP_CONTAINER_DIR/backup.dump"

# Log completion
echo "$(date): Restore script execution completed." >> $LOG_FILE

