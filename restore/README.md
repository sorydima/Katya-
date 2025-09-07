# Data Restoration Procedures

This directory contains detailed procedures for restoring data from backups, recovering from data loss incidents, and validating restoration integrity for the Katya project.

## Overview

Data restoration is a critical component of the disaster recovery strategy. This documentation provides comprehensive procedures for restoring data from various backup sources while ensuring data integrity and minimal service disruption.

## Restoration Types

### 1. Full System Restoration
**Purpose**: Complete recovery from catastrophic failure
**Scope**: Entire system including OS, applications, and data
**Use Case**: Hardware failure, data center loss, major corruption

### 2. Database Restoration
**Purpose**: Restore database to specific point in time
**Scope**: Database files and configurations
**Use Case**: Database corruption, accidental deletion, ransomware

### 3. File System Restoration
**Purpose**: Restore specific files or directories
**Scope**: Individual files, directories, or file systems
**Use Case**: Accidental file deletion, file corruption

### 4. Application Restoration
**Purpose**: Restore application binaries and configurations
**Scope**: Application code, dependencies, configurations
**Use Case**: Deployment failure, configuration corruption

### 5. Point-in-Time Restoration
**Purpose**: Restore to specific moment before incident
**Scope**: Database or file system state at specific time
**Use Case**: Data corruption, malicious activity

## Restoration Prerequisites

### Environment Preparation
- [ ] Verify backup integrity before restoration
- [ ] Prepare restoration environment (staging area)
- [ ] Ensure sufficient storage space for restoration
- [ ] Validate network connectivity to backup storage
- [ ] Confirm restoration team availability

### Access Requirements
- [ ] Backup storage access credentials
- [ ] Database administrative privileges
- [ ] System administrative access
- [ ] Application deployment permissions
- [ ] Network and firewall access

### Safety Measures
- [ ] Create restoration test environment
- [ ] Document current system state
- [ ] Backup current state before restoration
- [ ] Prepare rollback procedures
- [ ] Notify stakeholders of restoration schedule

## Database Restoration Procedures

### PostgreSQL Restoration
```bash
#!/bin/bash
# PostgreSQL Database Restoration Script

# Configuration
BACKUP_FILE="/backups/katya_db_2024-01-15_14-30.sql.gz"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="katya_production"
DB_USER="katya_admin"
RESTORE_LOG="/var/log/postgres_restore.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$RESTORE_LOG"
}

# Pre-restoration checks
log "Starting PostgreSQL restoration process"
log "Backup file: $BACKUP_FILE"
log "Target database: $DB_NAME"

# Verify backup file exists and is readable
if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file does not exist: $BACKUP_FILE"
    exit 1
fi

# Check backup file integrity
log "Verifying backup file integrity..."
gunzip -t "$BACKUP_FILE"
if [ $? -ne 0 ]; then
    log "ERROR: Backup file is corrupted"
    exit 1
fi

# Stop application services
log "Stopping application services..."
sudo systemctl stop katya-app
sudo systemctl stop katya-api

# Create restoration backup
log "Creating pre-restoration backup..."
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    | gzip > "/backups/pre_restore_$(date +%Y%m%d_%H%M%S).sql.gz"

# Terminate active connections
log "Terminating active database connections..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
    -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();"

# Drop and recreate database
log "Dropping and recreating database..."
dropdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME"
createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME"

# Restore from backup
log "Restoring database from backup..."
gunzip -c "$BACKUP_FILE" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"

# Validate restoration
log "Validating restoration..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    -c "SELECT COUNT(*) FROM users;" > /dev/null

if [ $? -eq 0 ]; then
    log "Database restoration completed successfully"
else
    log "ERROR: Database restoration validation failed"
    exit 1
fi

