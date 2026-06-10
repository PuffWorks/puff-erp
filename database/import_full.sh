#!/usr/bin/env bash
set -euo pipefail
DB_NAME="${DB_NAME:-hardware_erp_mvp}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
SQL_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Hardware20260607_1_full.sql"
MYSQL_ARGS=(-h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER")
if [ -n "$DB_PASSWORD" ]; then MYSQL_ARGS+=("-p$DB_PASSWORD"); else MYSQL_ARGS+=("-p"); fi
mysql "${MYSQL_ARGS[@]}" -e "CREATE DATABASE IF NOT EXISTS \`\ DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql "${MYSQL_ARGS[@]}" "$DB_NAME" < "$SQL_FILE"
echo "Database imported successfully."