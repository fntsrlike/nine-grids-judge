#!/bin/bash

DATE=$(date +"%Y-%m-%d-%T")

# Backup file information
BACKUP_LOCATION="/backups"
BACKUP_NAME="nine-grids-backup"
BACKUP_FILE_FULL_NAME="$BACKUP_LOCATION/$BACKUP_NAME-$DATE.sql"
QUESTIONS_BACKUP_FILE_FULL_NAME="$BACKUP_LOCATION/$BACKUP_NAME-chapters-questions-only-$DATE.sql"

# Database information
DB_USER="root"
DB_PASSWORD="123456"
DB_NAME="nine_grids"

# Executes backup
sudo mkdir $BACKUP_LOCATION 2>/dev/null
sudo mysqldump -u $DB_USER -p$DB_PASSWORD --opt $DB_NAME > $BACKUP_FILE_FULL_NAME 2>/dev/null
sudo mysqldump -u $DB_USER -p$DB_PASSWORD --opt $DB_NAME chapters quizzes > $QUESTIONS_BACKUP_FILE_FULL_NAME 2>/dev/null
