#!/usr/bin/env bash
set -euo pipefail
APP_ROOT="${APP_ROOT:-/www/wwwroot/hardware-erp}"
UPLOAD_ROOT="${UPLOAD_ROOT:-/www/wwwdata/hardware-erp/uploads}"
DB_MODE="${DB_MODE:-skip}"
DB_NAME="${DB_NAME:-hardware_erp_mvp}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
MIGRATION_FROM="${MIGRATION_FROM:-001}"
MIGRATION_TO="${MIGRATION_TO:-069}"
OVERWRITE_CONFIG="${OVERWRITE_CONFIG:-0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${BACKUP_ROOT:-/www/backup/hardware-erp}"
STAMP="$(date +%Y%m%d-%H%M%S)"
EXISTING_CONFIG_BACKUP=""

echo "Creating directories..."
mkdir -p "$APP_ROOT" "$UPLOAD_ROOT" "$BACKUP_ROOT"

if [ -d "$APP_ROOT/frontend" ] || [ -d "$APP_ROOT/backend" ]; then
  echo "Backing up existing files..."
  mkdir -p "$BACKUP_ROOT/files-$STAMP"
  [ -d "$APP_ROOT/frontend" ] && cp -a "$APP_ROOT/frontend" "$BACKUP_ROOT/files-$STAMP/"
  [ -d "$APP_ROOT/backend" ] && cp -a "$APP_ROOT/backend" "$BACKUP_ROOT/files-$STAMP/"
fi

if [ -f "$APP_ROOT/backend/config.yaml" ]; then
  EXISTING_CONFIG_BACKUP="$BACKUP_ROOT/config-$STAMP.yaml"
  cp -a "$APP_ROOT/backend/config.yaml" "$EXISTING_CONFIG_BACKUP"
  echo "Backed up existing config: $EXISTING_CONFIG_BACKUP"
fi

echo "Deploying new files..."
mkdir -p "$APP_ROOT/frontend" "$APP_ROOT/backend" "$APP_ROOT/database" "$APP_ROOT/nginx"
cp -a "$SCRIPT_DIR/frontend/." "$APP_ROOT/frontend/"
cp -a "$SCRIPT_DIR/backend/." "$APP_ROOT/backend/"
cp -a "$SCRIPT_DIR/database/." "$APP_ROOT/database/"
cp -a "$SCRIPT_DIR/nginx/." "$APP_ROOT/nginx/"

if [ -n "$EXISTING_CONFIG_BACKUP" ] && [ "$OVERWRITE_CONFIG" != "1" ]; then
  cp -a "$EXISTING_CONFIG_BACKUP" "$APP_ROOT/backend/config.yaml"
  echo "Restored existing config.yaml"
fi

chmod +x "$APP_ROOT/backend/hardware-erp" "$APP_ROOT/backend/start.sh"
chmod +x "$APP_ROOT/database/import_full.sh" "$APP_ROOT/database/apply_migrations.sh"

case "$DB_MODE" in
  full)
    echo "Importing full database..."
    DB_NAME="$DB_NAME" DB_USER="$DB_USER" DB_PASSWORD="$DB_PASSWORD" DB_HOST="$DB_HOST" DB_PORT="$DB_PORT" "$APP_ROOT/database/import_full.sh"
    ;;
  migrate)
    echo "Applying database migrations..."
    DB_NAME="$DB_NAME" DB_USER="$DB_USER" DB_PASSWORD="$DB_PASSWORD" DB_HOST="$DB_HOST" DB_PORT="$DB_PORT" MIGRATION_FROM="$MIGRATION_FROM" MIGRATION_TO="$MIGRATION_TO" "$APP_ROOT/database/apply_migrations.sh"
    ;;
  skip)
    echo "Skipping database operations (DB_MODE=skip)."
    ;;
  *)
    echo "Unknown DB_MODE: $DB_MODE. Use full, migrate, or skip." >&2
    exit 1
    ;;
esac

if command -v systemctl >/dev/null 2>&1; then
  echo "Installing systemd service..."
  cp "$APP_ROOT/backend/systemd/hardware-erp-api.service" /etc/systemd/system/hardware-erp-api.service
  systemctl daemon-reload
  systemctl enable hardware-erp-api
  systemctl restart hardware-erp-api
  echo "Service restarted."
fi

echo ""
echo "=========================================="
echo "Install/update finished successfully!"
echo "=========================================="
echo "App root: $APP_ROOT"
echo "Backups: $BACKUP_ROOT"
echo "Database mode: $DB_MODE"
if [ -n "$EXISTING_CONFIG_BACKUP" ] && [ "$OVERWRITE_CONFIG" != "1" ]; then
  echo "Config preserved: $EXISTING_CONFIG_BACKUP"
fi
echo ""
echo "Check service status:"
echo "  systemctl status hardware-erp-api"
echo "  curl http://127.0.0.1:8080/healthz"
echo ""