#!/bin/bash

# Current date in YYYY-MM-DD-HHMMSS format for unique restore filenames
DATE=$(date +%F-%H%M%S)

# Backup directory on the host
BACKUP_DIR="/home/akhil/db-backup/postgres/backup"  # Update to the desired backup directory for PostgreSQL

# Log directory and file
LOG_DIR="/home/akhil/db-backup/postgres/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/restore_log.txt"

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Ensure that LOG_FILE is a file, not a directory
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Log start time
echo "Restore started at $(date)" >> $LOG_FILE

# Database credentials and details
CONTAINER_NAME="postgres"  
DB_USER="root"           
DB_PASSWORD="root"       
DB_NAME="akhil"          

# Find the latest .sql file (backup file)
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.sql | head -n 1)

# Check if there are any .sql files found
if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup files found in the directory." >> $LOG_FILE
    exit 1
fi

echo "Latest backup file: $LATEST_BACKUP" >> $LOG_FILE

# Check if the database exists, create it if it doesn't
DB_EXISTS=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")

if [ -z "$DB_EXISTS" ]; then
    echo "Database '$DB_NAME' does not exist. Creating it now." >> $LOG_FILE
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"
    echo "Database '$DB_NAME' created." >> $LOG_FILE
else
    echo "Database '$DB_NAME' already exists. Proceeding with restore." >> $LOG_FILE
fi

# Restore the database using pg_restore inside the container
cat "$LATEST_BACKUP" | docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME

# Check for errors during restore
if [ $? -eq 0 ]; then
    echo "Restore successful: $LATEST_BACKUP" >> $LOG_FILE
else
    echo "Restore failed at $(date)" >> $LOG_FILE
fi

# Log completion time
echo "Restore completed at $(date)" >> $LOG_FILE
