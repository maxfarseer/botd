#!/bin/bash
set -euo pipefail

TARBALL="$1"
DEPLOY_DIR="/opt/botd/current"

echo "==> Stopping service..."
sudo systemctl stop botd || true

echo "==> Extracting release..."
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
tar -xzf "$TARBALL" -C "$DEPLOY_DIR"

echo "==> Backing up database..."
BACKUP_DIR="/opt/botd/backups"
mkdir -p "$BACKUP_DIR"
set -a
source /etc/botd.env
set +a
pg_dump botd_prod > "$BACKUP_DIR/pre-deploy-$(date +%Y%m%d%H%M%S).sql"

echo "==> Running migrations..."
"$DEPLOY_DIR/bin/migrate"

echo "==> Starting service..."
sudo systemctl start botd

echo "==> Deploy complete!"
sleep 3
sudo systemctl status botd --no-pager
