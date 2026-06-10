#!/usr/bin/env bash
set -euo pipefail
DB_NAME="${DB_NAME:-hardware_erp_mvp}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
MIGRATION_FROM="${MIGRATION_FROM:-001}"
MIGRATION_TO="${MIGRATION_TO:-069}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
BACKUP_ROOT="${BACKUP_ROOT:-/www/backup/hardware-erp}"
STAMP="$(date +%Y%m%d-%H%M%S)"
MYSQL_ARGS=(-h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER")
if [ -n "$DB_PASSWORD" ]; then MYSQL_ARGS+=("-p$DB_PASSWORD"); else MYSQL_ARGS+=("-p"); fi
mkdir -p "$BACKUP_ROOT"
mysqldump "${MYSQL_ARGS[@]}" --single-transaction --routines --triggers "$DB_NAME" > "$BACKUP_ROOT/$DB_NAME-before-migrations-$MIGRATION_FROM-$MIGRATION_TO-$STAMP.sql"
for migration in "$MIGRATIONS_DIR"/*.sql; do
  [ -f "$migration" ] || continue
  name="$(basename "$migration")"
  prefix="${name%%_*}"
  if [[ "$prefix" < "$MIGRATION_FROM" ]]; then continue; fi
  if [ -n "$MIGRATION_TO" ] && [[ "$prefix" > "$MIGRATION_TO" ]]; then continue; fi
  echo "Applying migration: $name"
  mysql "${MYSQL_ARGS[@]}" "$DB_NAME" < "$migration"
done
echo "Applied migrations $MIGRATION_FROM..$MIGRATION_TO to $DB_NAME."
echo "Backup: $BACKUP_ROOT/$DB_NAME-before-migrations-$MIGRATION_FROM-$MIGRATION_TO-$STAMP.sql"