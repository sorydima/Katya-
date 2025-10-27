# Backup Script for Katya Project

# Create backup directory
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup code
git add .
git commit -m "Auto backup: $(date)"
git push origin main

# Backup databases and configs
cp -r lib/ $BACKUP_DIR/
cp -r docs/ $BACKUP_DIR/
cp -r blockchain/ $BACKUP_DIR/
cp -r ai/ $BACKUP_DIR/

# Create tar archive
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR

echo "Backup created: $BACKUP_DIR.tar.gz"
