# Database Notes

- Primary database: MySQL 8.x
- Cache and auxiliary coordination: Redis
- Initial schema lives in [001_init_schema.sql](/z:/VUE/erp_gpt_20260507/migrations/001_init_schema.sql)
- Seed data lives in [002_seed_data.sql](/z:/VUE/erp_gpt_20260507/migrations/002_seed_data.sql)
- Business closure migration lives in [003_business_closure.sql](/z:/VUE/erp_gpt_20260507/migrations/003_business_closure.sql)
- Contract management upgrade for existing databases lives in [004_contract_management.sql](/z:/VUE/erp_gpt_20260507/migrations/004_contract_management.sql)

Current schema is intentionally lightweight and focuses on:

- authentication and RBAC
- numbering fallback
- operation audit
- placeholder domain tables for scaffolded ERP modules

Domain detail tables such as quotation items, sales order items, stock ledger, receivables, payables, and SN lifecycle should be expanded module by module during feature implementation.
