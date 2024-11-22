#!/bin/bash

# Backup directory on the host
BACKUP_DIR="/backup"  # Backup directory

# Find and delete files older than 5 hours (300 minutes)
find $BACKUP_DIR -type f -name "*.sql.gz" -mmin +300 -exec rm -f {} \;

# Optional: Log the deletion
echo "Cleanup completed at $(date)" >> /home/akhil/db-backup/logs/cleanup_log.txt

