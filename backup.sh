#!/usr/bin/env bash
# backup.sh — backup AFFiNE data (postgres + blobs)
# Usage: ./backup.sh [destination_dir]

set -euo pipefail

BACKUP_ROOT="${1:-./backups}"
DATE=$(date +%Y%m%d_%H%M%S)
DEST="$BACKUP_ROOT/$DATE"

mkdir -p "$DEST"

echo "📦 Backing up AFFiNE to $DEST ..."

# 1. PostgreSQL dump
echo "  → Dumping PostgreSQL..."
docker exec affine_postgres pg_dump -U "${DB_USERNAME:-affine}" "${DB_DATABASE:-affine}" \
  | gzip > "$DEST/postgres.sql.gz"

# 2. Blob storage
UPLOAD_LOCATION="${UPLOAD_LOCATION:-./affine/storage}"
if [ -d "$UPLOAD_LOCATION" ]; then
  echo "  → Copying blob storage..."
  cp -r "$UPLOAD_LOCATION" "$DEST/storage"
fi

# 3. Config
CONFIG_LOCATION="${CONFIG_LOCATION:-./affine/config}"
if [ -d "$CONFIG_LOCATION" ]; then
  echo "  → Copying config..."
  cp -r "$CONFIG_LOCATION" "$DEST/config"
fi

echo "✅ Backup complete: $DEST"
echo ""
echo "Files:"
ls -lh "$DEST"
