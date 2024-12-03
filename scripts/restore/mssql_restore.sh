#!/bin/bash

# Define variables
BACKUP_DIR="/home/akhil/db-backup/mssql/backup" 
CONTAINER_NAME="mssql"                       
BACKUP_CONTAINER_DIR="/var/opt/mssql/backup" 
DB_NAME="akhil"                              
SA_PASSWORD="Asd1234."                       
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"       

LOG_DIR="/home/akhil/db-backup/mssql/logs"  # Change to where you want your logs stored
LOG_FILE="$LOG_DIR/restore_log.txt"

# Create log file if it doesn't exist
touch $LOG_FILE

# Find the latest .bak file in the backup directory
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.bak | head -n 1)

# Check if there are any .bak files found
if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup files found in the directory." >> $LOG_FILE
    exit 1
fi

echo "Latest backup file: $LATEST_BACKUP" >> $LOG_FILE

# Copy the latest .bak file from host to container
docker cp "$LATEST_BACKUP" "$CONTAINER_NAME:$BACKUP_CONTAINER_DIR/backup.bak"


# Adjust permissions to allow SQL Server to access the backup file (run as root)
docker exec -u root -it "$CONTAINER_NAME" /bin/bash -c "
  chmod 777 $BACKUP_CONTAINER_DIR/backup.bak
  chown mssql:mssql $BACKUP_CONTAINER_DIR/backup.bak
"

# Run SQL restore command inside the container
docker exec -it "$CONTAINER_NAME" /bin/bash -c "
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '$SA_PASSWORD' -C -Q \
  \"RESTORE DATABASE $DB_NAME FROM DISK = '$BACKUP_CONTAINER_DIR/backup.bak' WITH REPLACE\"
"

echo "Database restore completed from the latest backup." >> $LOG_FILE

