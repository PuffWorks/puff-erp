# Build Manifest

Package: Hardware20260607_1
Build date: 2026-06-07 14:44:00
Target OS: Linux CentOS 7.9 x86_64

## Build Inputs

- Frontend source: ele-admin-plus-ts-pro-erp
- Frontend command: npm run build
- Backend source: hardware-erp/cmd/api
- Backend command: CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/hardware-erp-api-linux-amd64 ./cmd/api
- Database full SQL: hardware-erp/migrations/all.sql
- Database migrations included: 001-069 (69 files)

## Package Contents

- Frontend files: 1112
- Backend binary: hardware-erp-api-linux-amd64
- Database migration files: 69
- Configuration files: config.yaml, nginx.conf, systemd service
- Deployment scripts: server_install_or_update.sh, import_full.sh, apply_migrations.sh

## Included Runtime Files

- frontend/ (Vite production build)
- backend/hardware-erp (Linux amd64 binary)
- backend/config.yaml (production config template)
- backend/license_public.key
- backend/docs/ (API documentation)
- database/Hardware20260607_1_full.sql (complete database)
- database/hardware_erp_full.sql (alias)
- database/migrations/*.sql (individual migration files)
- nginx/hardware-erp.conf (Nginx configuration)
- server_install_or_update.sh (deployment script)

## Deployment Modes

- **DB_MODE=full**: Fresh installation with full database import
- **DB_MODE=migrate**: Apply specific migration range to existing database
- **DB_MODE=skip**: Update application files only, skip database operations

## Notes

This is a production-ready deployment package. Before deploying:
1. Modify backend/config.yaml with actual database credentials
2. Change jwt.secret to a random string (minimum 32 characters)
3. Update Redis password if authentication is enabled
4. Review and adjust Nginx configuration for your domain
5. Change default admin password immediately after first login