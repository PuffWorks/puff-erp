#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${APP_DIR:-$SCRIPT_DIR}"
UPLOAD_ROOT="${UPLOAD_ROOT:-/www/wwwdata/hardware-erp/uploads}"
cd "$APP_DIR"
mkdir -p "$APP_DIR/logs" "$UPLOAD_ROOT"
chmod +x ./hardware-erp
exec ./hardware-erp -config ./config.yaml