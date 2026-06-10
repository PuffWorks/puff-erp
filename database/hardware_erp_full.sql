-- Consolidated migration SQL for hardware-erp
-- Generated from migrations/*.sql in filename order on 2026-06-07 14:18:10
-- Source files: 69
-- Included files:
--   - 001_init_schema.sql
--   - 002_seed_data.sql
--   - 003_business_closure.sql
--   - 004_contract_management.sql
--   - 005_system_management.sql
--   - 006_action_permissions.sql
--   - 007_business_attachments.sql
--   - 008_rbac_permission_config.sql
--   - 009_system_foundation.sql
--   - 010_go_live_foundation.sql
--   - 011_go_live_route_alignment.sql
--   - 012_frontend_route_alignment.sql
--   - 013_menu_route_cleanup.sql
--   - 014_route_contract_hardening.sql
--   - 015_log_retention.sql
--   - 016_data_scope_ownership.sql
--   - 017_permission_boundary_fix.sql
--   - 018_data_permission_closure.sql
--   - 019_data_permission_flow_fix.sql
--   - 020_sales_role_hierarchy.sql
--   - 021_order_profit_snapshots.sql
--   - 022_purchase_price_for_purchase_role.sql
--   - 023_sales_sku_stock_visibility.sql
--   - 024_order_contact_snapshot_fix.sql
--   - 025_query_indexes.sql
--   - 026_simplified_chinese_display_names.sql
--   - 027_customer_code_auto_generate.sql
--   - 028_operation_log_request_fields.sql
--   - 029_finance_phase1_payment_workflow.sql
--   - 030_export_permission_super_admin_only.sql
--   - 031_customer_visibility_sales_only.sql
--   - 032_product_brand_category_foundation.sql
--   - 033_master_data_linkage_upgrade.sql
--   - 034_dashboard_report_phase1_upgrade.sql
--   - 035_system_profile_menu.sql
--   - 036_system_app_setting.sql
--   - 037_product_sku_code_permissions.sql
--   - 038_inventory_check_phase1.sql
--   - 039_master_data_linkage_rules.sql
--   - 040_phase1_business_closure.sql
--   - 041_fix_admin_default_password.sql
--   - 042_system_license.sql
--   - 043_system_impersonation.sql
--   - 044_erp15_three_line_closure.sql
--   - 045_inventory_phase1_state_closure.sql
--   - 046_finance_phase2_closure.sql
--   - 047_finance_invoice_expense_audit.sql
--   - 048_finance_phase2_acceptance_fix.sql
--   - 049_phase3_evidence_chain.sql
--   - 050_phase3_biz_relation_backfill.sql
--   - 051_phase3_gross_profit_report.sql
--   - 052_phase3_relation_source_no_fix.sql
--   - 053_serial_number_records_schema_guard.sql
--   - 054_serial_number_records_collation_fix.sql
--   - 055_crm_customer_operation.sql
--   - 056_deprecate_legacy_customer_permissions.sql
--   - 057_crm_sales_process_phase2.sql
--   - 058_crm_dashboard_funnel.sql
--   - 059_dashboard_real_data_access_fix.sql
--   - 060_crm_customer_pool_operation.sql
--   - 061_aftersales_service_closure.sql
--   - 062_sku_warranty_month.sql
--   - 063_aftersales_phase34.sql
--   - 064_aftersales_phase56.sql
--   - 065_frontend_route_404_compat.sql
--   - 066_dashboard_home_global_fix.sql
--   - 067_restore_workplace_menu.sql
--   - 068_import_center_2.sql
--   - 069_product_sku_stock_import.sql

-- ============================================================================
-- Source: 001_init_schema.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_users_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS roles (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_roles_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS menus (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    path VARCHAR(255) NOT NULL,
    component VARCHAR(255) NOT NULL DEFAULT '',
    redirect VARCHAR(255) NOT NULL DEFAULT '',
    title VARCHAR(128) NOT NULL,
    icon VARCHAR(64) NOT NULL DEFAULT '',
    sort INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_menus (
    role_id BIGINT UNSIGNED NOT NULL,
    menu_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, menu_id)
);

CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(128) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id BIGINT UNSIGNED NOT NULL,
    permission_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS number_sequences (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    biz_type VARCHAR(32) NOT NULL,
    biz_date VARCHAR(8) NOT NULL,
    current_value BIGINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_number_sequences (biz_type, biz_date)
);

CREATE TABLE IF NOT EXISTS operation_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    module_name VARCHAR(64) NOT NULL,
    action_name VARCHAR(64) NOT NULL,
    business_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    before_data JSON NULL,
    after_data JSON NULL,
    request_id VARCHAR(64) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_operation_logs_module_name (module_name),
    KEY idx_operation_logs_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS customers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    address VARCHAR(255) NOT NULL DEFAULT '',
    level VARCHAR(32) NOT NULL DEFAULT 'normal',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_customers_name (name),
    KEY idx_customers_status (status),
    KEY idx_customers_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS suppliers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    address VARCHAR(255) NOT NULL DEFAULT '',
    settlement_day INT NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_suppliers_name (name),
    KEY idx_suppliers_status (status),
    KEY idx_suppliers_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    brand VARCHAR(64) NOT NULL DEFAULT '',
    category VARCHAR(64) NOT NULL DEFAULT '',
    model VARCHAR(128) NOT NULL DEFAULT '',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    sn_enabled TINYINT(1) NOT NULL DEFAULT 0,
    warranty_month INT NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_products_name (name),
    KEY idx_products_status (status),
    KEY idx_products_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS skus (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    spec VARCHAR(255) NOT NULL DEFAULT '',
    barcode VARCHAR(64) NOT NULL DEFAULT '',
    cost_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    sales_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    purchase_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    warranty_month INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_skus_product_id (product_id),
    KEY idx_skus_status (status),
    KEY idx_skus_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS warehouses (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    manager VARCHAR(64) NOT NULL DEFAULT '',
    phone VARCHAR(64) NOT NULL DEFAULT '',
    address VARCHAR(255) NOT NULL DEFAULT '',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_warehouses_name (name),
    KEY idx_warehouses_status (status),
    KEY idx_warehouses_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS projects (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_projects_customer_id (customer_id),
    KEY idx_projects_status (status),
    KEY idx_projects_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS quotations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    quotation_no VARCHAR(64) NOT NULL UNIQUE,
    customer_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    currency VARCHAR(16) NOT NULL DEFAULT 'CNY',
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    confirmed_at DATETIME NULL,
    submitted_at DATETIME NULL,
    converted_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_quotations_customer_id (customer_id),
    KEY idx_quotations_project_id (project_id),
    KEY idx_quotations_status (status),
    KEY idx_quotations_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS quotation_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    quotation_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    cost_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    discount_rate DECIMAL(10,4) NOT NULL DEFAULT 1,
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    gross_profit DECIMAL(18,4) NOT NULL DEFAULT 0,
    gross_margin DECIMAL(10,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_quotation_items_quotation_id (quotation_id),
    KEY idx_quotation_items_sku_id (sku_id)
);

CREATE TABLE IF NOT EXISTS sales_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sales_order_no VARCHAR(64) NOT NULL UNIQUE,
    source_quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    currency VARCHAR(16) NOT NULL DEFAULT 'CNY',
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    shipped_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    confirmed_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_sales_orders_customer_id (customer_id),
    KEY idx_sales_orders_project_id (project_id),
    KEY idx_sales_orders_source_quotation_id (source_quotation_id),
    KEY idx_sales_orders_status (status),
    KEY idx_sales_orders_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS sales_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sales_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    shipped_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    cost_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    discount_rate DECIMAL(10,4) NOT NULL DEFAULT 1,
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    gross_profit DECIMAL(18,4) NOT NULL DEFAULT 0,
    gross_margin DECIMAL(10,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_sales_order_items_sales_order_id (sales_order_id),
    KEY idx_sales_order_items_sku_id (sku_id)
);

CREATE TABLE IF NOT EXISTS contract_templates (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    template_no VARCHAR(50) NOT NULL UNIQUE,
    template_name VARCHAR(100) NOT NULL,
    template_type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL DEFAULT '1.0',
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'enabled',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contract_templates_type (template_type),
    KEY idx_contract_templates_status (status),
    KEY idx_contract_templates_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contracts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_no VARCHAR(50) NOT NULL UNIQUE,
    contract_name VARCHAR(100) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    purchase_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contract_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    sign_date DATE NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contracts_type (contract_type),
    KEY idx_contracts_customer_id (customer_id),
    KEY idx_contracts_supplier_id (supplier_id),
    KEY idx_contracts_project_id (project_id),
    KEY idx_contracts_quotation_id (quotation_id),
    KEY idx_contracts_sales_order_id (sales_order_id),
    KEY idx_contracts_purchase_order_id (purchase_order_id),
    KEY idx_contracts_status (status),
    KEY idx_contracts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contract_files (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_id BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    file_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    upload_type VARCHAR(30) NOT NULL DEFAULT 'manual',
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NULL,
    KEY idx_contract_files_contract_id (contract_id),
    KEY idx_contract_files_status (status)
);

CREATE TABLE IF NOT EXISTS receivables (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    receivable_no VARCHAR(64) NOT NULL UNIQUE,
    sales_order_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    received_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    due_date DATE NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_receivables_sales_order_id (sales_order_id),
    KEY idx_receivables_customer_id (customer_id),
    KEY idx_receivables_status (status),
    KEY idx_receivables_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS payables (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    payable_no VARCHAR(64) NOT NULL UNIQUE,
    purchase_order_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    paid_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    due_date DATE NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_payables_purchase_order_id (purchase_order_id),
    KEY idx_payables_supplier_id (supplier_id),
    KEY idx_payables_status (status),
    KEY idx_payables_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS receipts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    receipt_no VARCHAR(64) NOT NULL UNIQUE,
    receivable_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_receipts_receivable_id (receivable_id),
    KEY idx_receipts_customer_id (customer_id),
    KEY idx_receipts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS payments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    payment_no VARCHAR(64) NOT NULL UNIQUE,
    payable_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_payments_payable_id (payable_id),
    KEY idx_payments_supplier_id (supplier_id),
    KEY idx_payments_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS finance_writeoffs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    writeoff_no VARCHAR(64) NOT NULL UNIQUE,
    writeoff_type VARCHAR(32) NOT NULL,
    target_id BIGINT UNSIGNED NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'done',
    reversed_at DATETIME NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_finance_writeoffs_type_target (writeoff_type, target_id),
    KEY idx_finance_writeoffs_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    purchase_order_no VARCHAR(64) NOT NULL UNIQUE,
    source_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    warehouse_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    currency VARCHAR(16) NOT NULL DEFAULT 'CNY',
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    inbound_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_purchase_orders_sales (source_sales_order_id),
    KEY idx_purchase_orders_supplier_id (supplier_id),
    KEY idx_purchase_orders_status (status),
    KEY idx_purchase_orders_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    inbound_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    tax_rate DECIMAL(10,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_purchase_order_items_order_id (purchase_order_id),
    KEY idx_purchase_order_items_sku_id (sku_id)
);

CREATE TABLE IF NOT EXISTS inventory_stocks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    stock_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    available_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    locked_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    cost_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_inventory_stock (warehouse_id, sku_id),
    KEY idx_inventory_stocks_product_id (product_id)
);

CREATE TABLE IF NOT EXISTS inventory_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    biz_type VARCHAR(32) NOT NULL,
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    warehouse_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    change_type VARCHAR(32) NOT NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    before_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    after_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_inventory_records_biz (biz_type, biz_id),
    KEY idx_inventory_records_sku_id (sku_id),
    KEY idx_inventory_records_warehouse_id (warehouse_id)
);

CREATE TABLE IF NOT EXISTS inventory_inbound_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    inbound_order_no VARCHAR(64) NOT NULL UNIQUE,
    source_purchase_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_inventory_inbound_orders_purchase (source_purchase_order_id),
    KEY idx_inventory_inbound_orders_warehouse (warehouse_id),
    KEY idx_inventory_inbound_orders_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_inbound_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    inbound_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_inventory_inbound_items_order_id (inbound_order_id),
    KEY idx_inventory_inbound_items_sku_id (sku_id)
);

CREATE TABLE IF NOT EXISTS inventory_outbound_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    outbound_order_no VARCHAR(64) NOT NULL UNIQUE,
    source_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_biz_type VARCHAR(64) NOT NULL DEFAULT '',
    source_biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_biz_no VARCHAR(64) NOT NULL DEFAULT '',
    warehouse_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_inventory_outbound_orders_sales (source_sales_order_id),
    KEY idx_inventory_outbound_orders_warehouse (warehouse_id),
    KEY idx_inventory_outbound_orders_source_biz (source_biz_type, source_biz_id),
    KEY idx_inventory_outbound_orders_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_outbound_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    outbound_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_inventory_outbound_items_order_id (outbound_order_id),
    KEY idx_inventory_outbound_items_sku_id (sku_id)
);

CREATE TABLE IF NOT EXISTS serial_numbers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sn_code VARCHAR(128) NOT NULL UNIQUE,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'in_stock',
    inbound_at DATETIME NULL,
    outbound_at DATETIME NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_serial_numbers_sku_id (sku_id),
    KEY idx_serial_numbers_status (status),
    KEY idx_serial_numbers_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS aftersales (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_no VARCHAR(64) NOT NULL UNIQUE,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    serial_number_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    issue_desc VARCHAR(1000) NOT NULL DEFAULT '',
    parts_cost_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    process_result VARCHAR(1000) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    processed_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    processed_at DATETIME NULL,
    closed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_customer_id (customer_id),
    KEY idx_aftersales_status (status),
    KEY idx_aftersales_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS aftersales_part_requests (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    request_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    warehouse_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    outbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_order_no VARCHAR(64) NOT NULL DEFAULT '',
    total_cost_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    submitted_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    submitted_at DATETIME NULL,
    audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    audited_at DATETIME NULL,
    outbound_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_at DATETIME NULL,
    cancelled_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    cancelled_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_part_requests_ticket (ticket_id),
    KEY idx_aftersales_part_requests_status (status),
    KEY idx_aftersales_part_requests_outbound (outbound_order_id),
    KEY idx_aftersales_part_requests_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS aftersales_part_request_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    part_request_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_code VARCHAR(64) NOT NULL DEFAULT '',
    sku_name VARCHAR(128) NOT NULL DEFAULT '',
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_aftersales_part_request_items_request (part_request_id),
    KEY idx_aftersales_part_request_items_sku (sku_id)
);

CREATE TABLE IF NOT EXISTS aftersales_ticket_parts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    part_request_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    part_request_no VARCHAR(64) NOT NULL DEFAULT '',
    outbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_order_no VARCHAR(64) NOT NULL DEFAULT '',
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_code VARCHAR(64) NOT NULL DEFAULT '',
    sku_name VARCHAR(128) NOT NULL DEFAULT '',
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    sn_codes JSON NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_aftersales_ticket_parts_ticket (ticket_id),
    KEY idx_aftersales_ticket_parts_request (part_request_id),
    KEY idx_aftersales_ticket_parts_outbound (outbound_order_id)
);

CREATE TABLE IF NOT EXISTS aftersales_rma_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    rma_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_no VARCHAR(64) NOT NULL DEFAULT '',
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sn_code VARCHAR(128) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    problem_desc VARCHAR(1000) NOT NULL DEFAULT '',
    process_note VARCHAR(1000) NOT NULL DEFAULT '',
    sent_at DATETIME NULL,
    returned_at DATETIME NULL,
    closed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_rma_orders_ticket (ticket_id),
    KEY idx_aftersales_rma_orders_status (status),
    KEY idx_aftersales_rma_orders_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS aftersales_visits (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    visit_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    contact_name VARCHAR(100) NOT NULL DEFAULT '',
    contact_phone VARCHAR(100) NOT NULL DEFAULT '',
    handler_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    handler_user_name VARCHAR(100) NOT NULL DEFAULT '',
    visit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    visit_user_name VARCHAR(100) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    satisfaction VARCHAR(32) NOT NULL DEFAULT '',
    satisfaction_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    questionnaire JSON NULL,
    feedback VARCHAR(1000) NOT NULL DEFAULT '',
    improve_action VARCHAR(1000) NOT NULL DEFAULT '',
    next_action VARCHAR(64) NOT NULL DEFAULT '',
    new_ticket_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    new_ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    due_at DATETIME NULL,
    finished_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_visits_ticket (ticket_id),
    KEY idx_aftersales_visits_customer (customer_id),
    KEY idx_aftersales_visits_status (status),
    KEY idx_aftersales_visits_visit_user (visit_user_id),
    KEY idx_aftersales_visits_deleted_at (deleted_at)
);


-- ============================================================================
-- Source: 002_seed_data.sql
-- ============================================================================
INSERT INTO users (id, username, password_hash, display_name, status)
VALUES (1, 'admin', '$2a$10$yOcqosM6UTLC1GWy0lM/9.R742LAQkGzK26MSI3ICK/QRXhzZ3y36', '系统管理员', 'active')
ON DUPLICATE KEY UPDATE
password_hash = VALUES(password_hash),
display_name = VALUES(display_name),
status = VALUES(status);

INSERT INTO roles (id, code, name)
VALUES (1, 'super_admin', '超级管理员')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO user_roles (user_id, role_id)
VALUES (1, 1)
ON DUPLICATE KEY UPDATE
user_id = VALUES(user_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(1, 0, 'dashboard', '/dashboard', 'LAYOUT', '', '工作台', 'Odometer', 1),
(2, 0, 'system', '/system', 'LAYOUT', '/system/users', '系统管理', 'Setting', 2),
(3, 2, 'systemUsers', 'users', '/system/users/index', '', '用户管理', 'User', 1),
(4, 0, 'masterData', '/master-data', 'LAYOUT', '/master-data/customers', '基础资料', 'Collection', 3),
(5, 4, 'customers', 'customers', '/customer/index', '', '客户管理', 'UserFilled', 1),
(6, 4, 'products', 'products', '/product/index', '', '商品管理', 'Goods', 2),
(7, 0, 'sales', '/sales', 'LAYOUT', '/sales/quotations', '销售管理', 'Sell', 4),
(8, 7, 'quotations', 'quotations', '/quotation/index', '', '报价管理', 'Document', 1),
(9, 7, 'salesOrders', 'orders', '/sales/index', '', '销售订单', 'Tickets', 2),
(10, 0, 'inventory', '/inventory', 'LAYOUT', '/inventory/stocks', '库存管理', 'Box', 5),
(11, 10, 'stocks', 'stocks', '/inventory/stocks/index', '', '库存现存量', 'Box', 1)
ON DUPLICATE KEY UPDATE
title = VALUES(title),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1, 10),(1, 11)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(1, 'system:user:list', '查看用户'),
(2, 'system:role:list', '查看角色'),
(3, 'customer:list', '查看客户'),
(4, 'supplier:list', '查看供应商'),
(5, 'product:list', '查看商品'),
(6, 'warehouse:list', '查看仓库'),
(7, 'project:list', '查看项目'),
(8, 'quotation:list', '查看报价'),
(9, 'sales:list', '查看销售订单'),
(10, 'purchase:list', '查看采购订单'),
(11, 'inventory:list', '查看库存'),
(12, 'serial:list', '查看序列号'),
(13, 'aftersales:list', '查看售后'),
(14, 'finance:list', '查看财务'),
(15, 'dashboard:view', '查看工作台'),
(16, 'report:view', '查看报表')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),
(1, 9),(1, 10),(1, 11),(1, 12),(1, 13),(1, 14),(1, 15),(1, 16)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', 'Files', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3)
ON DUPLICATE KEY UPDATE
title = VALUES(title),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(17, 'contract:template:list', 'List contract templates'),
(18, 'contract:template:create', 'Create contract templates'),
(19, 'contract:template:update', 'Update contract templates'),
(20, 'contract:template:delete', 'Delete contract templates'),
(21, 'contract:template:download', 'Download contract templates'),
(22, 'contract:list', 'List contracts'),
(23, 'contract:create', 'Create contracts'),
(24, 'contract:update', 'Update contracts'),
(25, 'contract:delete', 'Delete contracts'),
(26, 'contract:upload', 'Upload contract files'),
(27, 'contract:download', 'Download contract files'),
(28, 'contract:sign', 'Sign contracts'),
(29, 'contract:cancel', 'Cancel contracts'),
(30, 'contract:complete', 'Complete contracts')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20),(1, 21),(1, 22),(1, 23),
(1, 24),(1, 25),(1, 26),(1, 27),(1, 28),(1, 29),(1, 30)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(21, 2, 'systemRoles', 'roles', '/system/role/index', '', '角色管理', 'UserFilled', 2),
(22, 2, 'systemMenus', 'menus', '/system/menu/index', '', '菜单管理', 'Menu', 3),
(23, 2, 'systemDicts', 'dicts', '/system/dictionary/index', '', '数据字典', 'Files', 4),
(24, 2, 'systemOperationLogs', 'operation-logs', '/system/operation-record/index', '', '操作日志', 'Tickets', 5)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 21),(1, 22),(1, 23),(1, 24)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(31, 'system:menu:list', 'List system menus'),
(32, 'system:dict:list', 'List dictionaries'),
(33, 'system:operation-log:list', 'List operation logs'),
(34, 'system:number-rule:list', 'List number rules')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 31),(1, 32),(1, 33),(1, 34)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(25, 2, 'systemNumberRules', 'number-rules', '/system/number-rules/index', '', '编号规则', 'Operation', 6),
(26, 4, 'suppliers', 'suppliers', '/supplier/index', '', '供应商管理', 'Van', 2),
(27, 4, 'skus', 'skus', '/sku/index', '', 'SKU管理', 'GoodsFilled', 4),
(28, 4, 'warehouses', 'warehouses', '/warehouse/index', '', '仓库管理', 'House', 5),
(29, 7, 'projects', 'projects', '/project/index', '', '项目管理', 'Folder', 1),
(30, 0, 'purchase', '/purchase', 'LAYOUT', '/purchase/orders', '采购管理', 'ShoppingCart', 7),
(31, 30, 'purchaseOrders', 'orders', '/purchase/index', '', '采购订单', 'Tickets', 1),
(32, 10, 'inboundOrders', 'inbound-orders', '/inventory/inbound-orders/index', '', '入库单', 'Download', 2),
(33, 10, 'outboundOrders', 'outbound-orders', '/inventory/outbound-orders/index', '', '出库单', 'Upload', 3),
(34, 10, 'inventoryRecords', 'records', '/inventory/records/index', '', '库存流水', 'Tickets', 4),
(35, 10, 'serialNumbers', 'serial-numbers', '/serial/index', '', 'SN管理', 'Cpu', 5),
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2),
(39, 0, 'finance', '/finance', 'LAYOUT', '/finance/receivables', '财务管理', 'Money', 10),
(40, 39, 'receivables', 'receivables', '/finance/receivables/index', '', '应收记录', 'Coin', 1),
(41, 39, 'payables', 'payables', '/finance/payables/index', '', '应付记录', 'Wallet', 2),
(42, 39, 'receipts', 'receipts', '/finance/receipts/index', '', '收款记录', 'DocumentChecked', 3),
(43, 39, 'payments', 'payments', '/finance/payments/index', '', '付款记录', 'CreditCard', 4),
(44, 0, 'reports', '/reports', 'LAYOUT', '/reports/sales', '报表中心', 'DataAnalysis', 11),
(45, 44, 'salesReport', 'sales', '/reports/sales/index', '', '销售报表', 'TrendCharts', 1),
(46, 44, 'purchaseReport', 'purchase', '/reports/purchase/index', '', '采购报表', 'ShoppingCart', 2),
(47, 44, 'inventoryReport', 'inventory', '/reports/inventory/index', '', '库存报表', 'Box', 3),
(48, 44, 'aftersalesReport', 'aftersales', '/reports/aftersales/index', '', '售后报表', 'Service', 4)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 25),(1, 26),(1, 27),(1, 28),(1, 29),(1, 30),(1, 31),(1, 32),
(1, 33),(1, 34),(1, 35),(1, 36),(1, 37),(1, 38),(1, 39),(1, 40),
(1, 41),(1, 42),(1, 43),(1, 44),(1, 45),(1, 46),(1, 47),(1, 48)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(35, 'system:role:create', 'Create roles'),
(36, 'system:role:update', 'Update roles'),
(37, 'system:role:delete', 'Delete roles'),
(38, 'system:menu:create', 'Create menus'),
(39, 'system:menu:update', 'Update menus'),
(40, 'system:menu:delete', 'Delete menus'),
(41, 'system:dict:create', 'Create dictionaries'),
(42, 'system:dict:update', 'Update dictionaries'),
(43, 'system:dict:delete', 'Delete dictionaries'),
(44, 'system:number-rule:create', 'Create number rules'),
(45, 'system:number-rule:update', 'Update number rules'),
(46, 'system:number-rule:delete', 'Delete number rules'),
(47, 'system:permission:list', 'List permissions'),
(48, 'finance:receipt:list', 'List receipts'),
(49, 'finance:payment:list', 'List payments'),
(50, 'report:sales', 'View sales report'),
(51, 'report:purchase', 'View purchase report'),
(52, 'report:inventory', 'View inventory report'),
(53, 'report:aftersales', 'View aftersales report')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 35),(1, 36),(1, 37),(1, 38),(1, 39),(1, 40),(1, 41),(1, 42),
(1, 43),(1, 44),(1, 45),(1, 46),(1, 47),(1, 48),(1, 49),(1, 50),
(1, 51),(1, 52),(1, 53)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);



-- ============================================================================
-- Source: 003_business_closure.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS contract_templates (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    template_no VARCHAR(50) NOT NULL UNIQUE,
    template_name VARCHAR(100) NOT NULL,
    template_type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL DEFAULT '1.0',
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'enabled',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contract_templates_type (template_type),
    KEY idx_contract_templates_status (status),
    KEY idx_contract_templates_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contracts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_no VARCHAR(50) NOT NULL UNIQUE,
    contract_name VARCHAR(100) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    purchase_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contract_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    sign_date DATE NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contracts_type (contract_type),
    KEY idx_contracts_customer_id (customer_id),
    KEY idx_contracts_supplier_id (supplier_id),
    KEY idx_contracts_project_id (project_id),
    KEY idx_contracts_quotation_id (quotation_id),
    KEY idx_contracts_sales_order_id (sales_order_id),
    KEY idx_contracts_purchase_order_id (purchase_order_id),
    KEY idx_contracts_status (status),
    KEY idx_contracts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contract_files (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_id BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    file_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    upload_type VARCHAR(30) NOT NULL DEFAULT 'manual',
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NULL,
    KEY idx_contract_files_contract_id (contract_id),
    KEY idx_contract_files_status (status)
);

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('purchase_orders', 'source_sales_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'purchase_order_no');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_sales', '`source_sales_order_id`');

CALL add_column_if_missing('aftersales', 'process_result', 'VARCHAR(1000) NOT NULL DEFAULT ''''', 'issue_desc');
CALL add_column_if_missing('aftersales', 'processed_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'status');
CALL add_column_if_missing('aftersales', 'processed_at', 'DATETIME NULL', 'processed_by');
CALL add_column_if_missing('aftersales', 'closed_at', 'DATETIME NULL', 'processed_at');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 004_contract_management.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS contract_templates (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    template_no VARCHAR(50) NOT NULL UNIQUE,
    template_name VARCHAR(100) NOT NULL,
    template_type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL DEFAULT '1.0',
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'enabled',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contract_templates_type (template_type),
    KEY idx_contract_templates_status (status),
    KEY idx_contract_templates_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contracts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_no VARCHAR(50) NOT NULL UNIQUE,
    contract_name VARCHAR(100) NOT NULL DEFAULT '',
    contract_type VARCHAR(50) NOT NULL DEFAULT 'sales',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    purchase_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    contract_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    sign_date DATE NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NULL,
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_contracts_type (contract_type),
    KEY idx_contracts_customer_id (customer_id),
    KEY idx_contracts_supplier_id (supplier_id),
    KEY idx_contracts_project_id (project_id),
    KEY idx_contracts_quotation_id (quotation_id),
    KEY idx_contracts_sales_order_id (sales_order_id),
    KEY idx_contracts_purchase_order_id (purchase_order_id),
    KEY idx_contracts_status (status),
    KEY idx_contracts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS contract_files (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    contract_id BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    file_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    upload_type VARCHAR(30) NOT NULL DEFAULT 'manual',
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NULL,
    KEY idx_contract_files_contract_id (contract_id),
    KEY idx_contract_files_status (status)
);

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('contracts', 'contract_no', 'VARCHAR(50) NOT NULL DEFAULT ''LEGACY''', 'id');
CALL add_column_if_missing('contracts', 'contract_name', 'VARCHAR(100) NOT NULL DEFAULT ''Legacy Contract''', 'contract_no');
CALL add_column_if_missing('contracts', 'contract_type', 'VARCHAR(50) NOT NULL DEFAULT ''sales''', 'contract_name');
CALL add_column_if_missing('contracts', 'customer_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'contract_type');
CALL add_column_if_missing('contracts', 'supplier_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'customer_id');
CALL add_column_if_missing('contracts', 'project_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'supplier_id');
CALL add_column_if_missing('contracts', 'quotation_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'project_id');
CALL add_column_if_missing('contracts', 'sales_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'quotation_id');
CALL add_column_if_missing('contracts', 'purchase_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'sales_order_id');
CALL add_column_if_missing('contracts', 'contract_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'purchase_order_id');
CALL add_column_if_missing('contracts', 'sign_date', 'DATE NULL', 'contract_amount');
CALL add_column_if_missing('contracts', 'start_date', 'DATE NULL', 'sign_date');
CALL add_column_if_missing('contracts', 'end_date', 'DATE NULL', 'start_date');
CALL add_column_if_missing('contracts', 'status', 'VARCHAR(30) NOT NULL DEFAULT ''draft''', 'end_date');
CALL add_column_if_missing('contracts', 'remark', 'VARCHAR(500) NULL', 'status');
CALL add_column_if_missing('contracts', 'created_by', 'BIGINT UNSIGNED NULL', 'remark');
CALL add_column_if_missing('contracts', 'updated_by', 'BIGINT UNSIGNED NULL', 'created_by');
CALL add_column_if_missing('contracts', 'created_at', 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP', 'updated_by');
CALL add_column_if_missing('contracts', 'updated_at', 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP', 'created_at');
CALL add_column_if_missing('contracts', 'deleted_at', 'DATETIME NULL', 'updated_at');

UPDATE contracts
SET contract_no = CONCAT('LEGACY', LPAD(id, 8, '0'))
WHERE contract_no = 'LEGACY' OR contract_no = '';

CALL add_index_if_missing('contracts', 'idx_contracts_type', '`contract_type`');
CALL add_index_if_missing('contracts', 'idx_contracts_customer_id', '`customer_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_supplier_id', '`supplier_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_project_id', '`project_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_quotation_id', '`quotation_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_sales_order_id', '`sales_order_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_purchase_order_id', '`purchase_order_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_status', '`status`');
CALL add_index_if_missing('contracts', 'idx_contracts_deleted_at', '`deleted_at`');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', 'Files', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(17, 'contract:template:list', 'List contract templates'),
(18, 'contract:template:create', 'Create contract templates'),
(19, 'contract:template:update', 'Update contract templates'),
(20, 'contract:template:delete', 'Delete contract templates'),
(21, 'contract:template:download', 'Download contract templates'),
(22, 'contract:list', 'List contracts'),
(23, 'contract:create', 'Create contracts'),
(24, 'contract:update', 'Update contracts'),
(25, 'contract:delete', 'Delete contracts'),
(26, 'contract:upload', 'Upload contract files'),
(27, 'contract:download', 'Download contract files'),
(28, 'contract:sign', 'Sign contracts'),
(29, 'contract:cancel', 'Cancel contracts'),
(30, 'contract:complete', 'Complete contracts')
ON DUPLICATE KEY UPDATE
code = VALUES(code),
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20),(1, 21),(1, 22),(1, 23),
(1, 24),(1, 25),(1, 26),(1, 27),(1, 28),(1, 29),(1, 30)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);


-- ============================================================================
-- Source: 005_system_management.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS system_dicts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_system_dicts_status (status),
    KEY idx_system_dicts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS system_dict_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    dict_id BIGINT UNSIGNED NOT NULL,
    label VARCHAR(128) NOT NULL,
    value VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_system_dict_item_value (dict_id, value),
    KEY idx_system_dict_items_dict_id (dict_id),
    KEY idx_system_dict_items_status (status),
    KEY idx_system_dict_items_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS number_rules (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    biz_type VARCHAR(32) NOT NULL UNIQUE,
    display_name VARCHAR(128) NOT NULL,
    prefix VARCHAR(16) NOT NULL,
    date_format VARCHAR(32) NOT NULL DEFAULT '20060102',
    sequence_length INT NOT NULL DEFAULT 4,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_number_rules_status (status),
    KEY idx_number_rules_deleted_at (deleted_at)
);

INSERT INTO system_dicts (id, code, name, status, remark) VALUES
(1, 'common_status', 'Common Status', 'active', ''),
(2, 'finance_status', 'Finance Status', 'active', ''),
(3, 'contract_status', 'Contract Status', 'active', ''),
(4, 'writeoff_status', 'Writeoff Status', 'active', '')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO system_dict_items (id, dict_id, label, value, sort, status, remark) VALUES
(1, 1, 'Active', 'active', 1, 'active', ''),
(2, 1, 'Disabled', 'disabled', 2, 'active', ''),
(3, 2, 'Pending', 'pending', 1, 'active', ''),
(4, 2, 'Partial', 'partial', 2, 'active', ''),
(5, 2, 'Paid', 'paid', 3, 'active', ''),
(6, 2, 'Voided', 'voided', 4, 'active', ''),
(7, 3, 'Draft', 'draft', 1, 'active', ''),
(8, 3, 'Signed', 'signed', 2, 'active', ''),
(9, 3, 'Active', 'active', 3, 'active', ''),
(10, 3, 'Completed', 'completed', 4, 'active', ''),
(11, 3, 'Cancelled', 'cancelled', 5, 'active', ''),
(12, 4, 'Done', 'done', 1, 'active', ''),
(13, 4, 'Reversed', 'reversed', 2, 'active', '')
ON DUPLICATE KEY UPDATE
label = VALUES(label),
sort = VALUES(sort),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO number_rules (id, biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
(1, 'quotation', 'Quotation', 'BJ', '20060102', 4, 'active', ''),
(2, 'sales_order', 'Sales Order', 'XS', '20060102', 4, 'active', ''),
(3, 'purchase_order', 'Purchase Order', 'CG', '20060102', 4, 'active', ''),
(4, 'inbound_order', 'Inbound Order', 'RK', '20060102', 4, 'active', ''),
(5, 'outbound_order', 'Outbound Order', 'CK', '20060102', 4, 'active', ''),
(6, 'aftersales', 'Aftersales Ticket', 'SH', '20060102', 4, 'active', ''),
(7, 'receivable', 'Receivable', 'YS', '20060102', 4, 'active', ''),
(8, 'payable', 'Payable', 'YF', '20060102', 4, 'active', ''),
(9, 'receipt', 'Receipt', 'SK', '20060102', 4, 'active', ''),
(10, 'payment', 'Payment', 'FK', '20060102', 4, 'active', ''),
(11, 'writeoff', 'Writeoff', 'HX', '20060102', 4, 'active', ''),
(12, 'contract', 'Contract', 'HT', '20060102', 4, 'active', ''),
(13, 'contract_template', 'Contract Template', 'MB', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);


-- ============================================================================
-- Source: 006_action_permissions.sql
-- ============================================================================
INSERT INTO permissions (id, code, name) VALUES
(54, 'quotation:create', 'Create quotations'),
(55, 'quotation:update', 'Update quotations'),
(56, 'quotation:delete', 'Delete quotations'),
(57, 'quotation:submit', 'Submit quotations'),
(58, 'quotation:audit', 'Audit quotations'),
(59, 'quotation:reject', 'Reject quotations'),
(60, 'quotation:unaudit', 'Unaudit quotations'),
(61, 'quotation:confirm', 'Confirm quotations'),
(62, 'quotation:convert', 'Convert quotations'),
(63, 'quotation:cancel', 'Cancel quotations'),
(64, 'quotation:export', 'Export quotations'),
(65, 'quotation:print', 'Print quotations'),
(66, 'quotation:copy', 'Copy quotations'),
(67, 'quotation:attachment', 'Manage quotation attachments'),
(68, 'quotation:log', 'View quotation logs'),
(69, 'quotation:viewCost', 'View quotation cost'),
(70, 'sales:create', 'Create sales orders'),
(71, 'sales:update', 'Update sales orders'),
(72, 'sales:delete', 'Delete sales orders'),
(73, 'sales:submit', 'Submit sales orders'),
(74, 'sales:audit', 'Audit sales orders'),
(75, 'sales:reject', 'Reject sales orders'),
(76, 'sales:unaudit', 'Unaudit sales orders'),
(77, 'sales:confirm', 'Confirm sales orders'),
(78, 'sales:checkStock', 'Check sales stock'),
(79, 'sales:generatePurchase', 'Generate purchase orders'),
(80, 'sales:outbound', 'Create sales outbound'),
(81, 'sales:cancel', 'Cancel sales orders'),
(82, 'sales:complete', 'Complete sales orders'),
(83, 'sales:export', 'Export sales orders'),
(84, 'sales:print', 'Print sales orders'),
(85, 'sales:attachment', 'Manage sales attachments'),
(86, 'sales:log', 'View sales logs'),
(87, 'purchase:create', 'Create purchase orders'),
(88, 'purchase:update', 'Update purchase orders'),
(89, 'purchase:delete', 'Delete purchase orders'),
(90, 'purchase:submit', 'Submit purchase orders'),
(91, 'purchase:audit', 'Audit purchase orders'),
(92, 'purchase:reject', 'Reject purchase orders'),
(93, 'purchase:unaudit', 'Unaudit purchase orders'),
(94, 'purchase:confirm', 'Confirm purchase orders'),
(95, 'purchase:inbound', 'Create purchase inbound'),
(96, 'purchase:cancel', 'Cancel purchase orders'),
(97, 'purchase:complete', 'Complete purchase orders'),
(98, 'purchase:export', 'Export purchase orders'),
(99, 'purchase:print', 'Print purchase orders'),
(100, 'purchase:attachment', 'Manage purchase attachments'),
(101, 'purchase:log', 'View purchase logs'),
(102, 'customer:create', 'Create customers'),
(103, 'customer:update', 'Update customers'),
(104, 'customer:delete', 'Delete customers'),
(105, 'customer:import', 'Import customers'),
(106, 'customer:export', 'Export customers'),
(107, 'customer:log', 'View customer logs'),
(108, 'supplier:create', 'Create suppliers'),
(109, 'supplier:update', 'Update suppliers'),
(110, 'supplier:delete', 'Delete suppliers'),
(111, 'supplier:import', 'Import suppliers'),
(112, 'supplier:export', 'Export suppliers'),
(113, 'supplier:log', 'View supplier logs'),
(114, 'product:create', 'Create products'),
(115, 'product:update', 'Update products'),
(116, 'product:delete', 'Delete products'),
(117, 'product:import', 'Import products'),
(118, 'product:export', 'Export products'),
(119, 'product:log', 'View product logs'),
(120, 'sku:list', 'List skus'),
(121, 'sku:create', 'Create skus'),
(122, 'sku:update', 'Update skus'),
(123, 'sku:delete', 'Delete skus'),
(124, 'sku:import', 'Import skus'),
(125, 'sku:export', 'Export skus'),
(126, 'sku:log', 'View sku logs'),
(127, 'warehouse:create', 'Create warehouses'),
(128, 'warehouse:update', 'Update warehouses'),
(129, 'warehouse:delete', 'Delete warehouses'),
(130, 'warehouse:import', 'Import warehouses'),
(131, 'warehouse:export', 'Export warehouses'),
(132, 'warehouse:log', 'View warehouse logs'),
(133, 'project:create', 'Create projects'),
(134, 'project:update', 'Update projects'),
(135, 'project:delete', 'Delete projects'),
(136, 'project:import', 'Import projects'),
(137, 'project:export', 'Export projects'),
(138, 'project:log', 'View project logs'),
(139, 'inventory:stock:list', 'List stock'),
(140, 'inventory:record:list', 'List inventory records'),
(141, 'inventory:inbound:list', 'List inbound orders'),
(142, 'inventory:inbound:create', 'Create inbound orders'),
(143, 'inventory:inbound:confirm', 'Confirm inbound orders'),
(144, 'inventory:outbound:list', 'List outbound orders'),
(145, 'inventory:outbound:create', 'Create outbound orders'),
(146, 'inventory:outbound:confirm', 'Confirm outbound orders'),
(147, 'inventory:export', 'Export inventory'),
(148, 'serial:select', 'Select serial numbers'),
(149, 'serial:scan', 'Scan serial numbers'),
(150, 'serial:export', 'Export serial numbers'),
(151, 'contract:print', 'Print contracts'),
(152, 'contract:log', 'View contract logs'),
(153, 'contract:template:upload', 'Upload contract templates'),
(154, 'finance:receivable:list', 'List receivables'),
(155, 'finance:payable:list', 'List payables'),
(156, 'finance:receipt:create', 'Create receipts'),
(157, 'finance:payment:create', 'Create payments'),
(158, 'finance:export', 'Export finance data'),
(159, 'finance:log', 'View finance logs'),
(160, 'finance:writeoff', 'Write off finance records'),
(161, 'aftersales:create', 'Create aftersales tickets'),
(162, 'aftersales:update', 'Update aftersales tickets'),
(163, 'aftersales:cancel', 'Cancel aftersales tickets'),
(164, 'aftersales:complete', 'Complete aftersales tickets'),
(165, 'aftersales:export', 'Export aftersales tickets'),
(166, 'aftersales:print', 'Print aftersales tickets'),
(167, 'aftersales:attachment', 'Manage aftersales attachments'),
(168, 'aftersales:log', 'View aftersales logs')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 54),(1, 55),(1, 56),(1, 57),(1, 58),(1, 59),(1, 60),(1, 61),
(1, 62),(1, 63),(1, 64),(1, 65),(1, 66),(1, 67),(1, 68),(1, 69),
(1, 70),(1, 71),(1, 72),(1, 73),(1, 74),(1, 75),(1, 76),(1, 77),
(1, 78),(1, 79),(1, 80),(1, 81),(1, 82),(1, 83),(1, 84),(1, 85),
(1, 86),(1, 87),(1, 88),(1, 89),(1, 90),(1, 91),(1, 92),(1, 93),
(1, 94),(1, 95),(1, 96),(1, 97),(1, 98),(1, 99),(1, 100),(1, 101),
(1, 102),(1, 103),(1, 104),(1, 105),(1, 106),(1, 107),(1, 108),(1, 109),
(1, 110),(1, 111),(1, 112),(1, 113),(1, 114),(1, 115),(1, 116),(1, 117),
(1, 118),(1, 119),(1, 120),(1, 121),(1, 122),(1, 123),(1, 124),(1, 125),
(1, 126),(1, 127),(1, 128),(1, 129),(1, 130),(1, 131),(1, 132),(1, 133),
(1, 134),(1, 135),(1, 136),(1, 137),(1, 138),(1, 139),(1, 140),(1, 141),
(1, 142),(1, 143),(1, 144),(1, 145),(1, 146),(1, 147),(1, 148),(1, 149),
(1, 150),(1, 151),(1, 152),(1, 153),(1, 154),(1, 155),(1, 156),(1, 157),
(1, 158),(1, 159),(1, 160),(1, 161),(1, 162),(1, 163),(1, 164),(1, 165),
(1, 166),(1, 167),(1, 168)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);


-- ============================================================================
-- Source: 007_business_attachments.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS business_attachments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    business_type VARCHAR(64) NOT NULL,
    business_id BIGINT UNSIGNED NOT NULL,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL DEFAULT '',
    file_size BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    KEY idx_business_attachments_biz (business_type, business_id),
    KEY idx_business_attachments_status (status),
    KEY idx_business_attachments_uploaded_at (uploaded_at)
);


-- ============================================================================
-- Source: 008_rbac_permission_config.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('roles', 'data_scope', 'VARCHAR(30) NOT NULL DEFAULT ''self'' COMMENT ''数据范围 all/team/self/custom''', 'name');
CALL add_column_if_missing('roles', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active'' COMMENT ''状态 active/disabled''', 'data_scope');
CALL add_column_if_missing('roles', 'remark', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''备注''', 'status');

CALL add_column_if_missing('permissions', 'parent_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''父级权限ID''', 'id');
CALL add_column_if_missing('permissions', 'permission_type', 'VARCHAR(30) NOT NULL DEFAULT ''button'' COMMENT ''menu/button/api/field''', 'name');
CALL add_column_if_missing('permissions', 'module', 'VARCHAR(50) NOT NULL DEFAULT '''' COMMENT ''模块''', 'permission_type');
CALL add_column_if_missing('permissions', 'path', 'VARCHAR(255) NOT NULL DEFAULT '''' COMMENT ''前端路由或接口路径''', 'module');
CALL add_column_if_missing('permissions', 'method', 'VARCHAR(20) NOT NULL DEFAULT '''' COMMENT ''接口方法''', 'path');
CALL add_column_if_missing('permissions', 'sort', 'INT NOT NULL DEFAULT 0 COMMENT ''排序''', 'method');
CALL add_column_if_missing('permissions', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active'' COMMENT ''状态 active/disabled''', 'sort');

DROP PROCEDURE IF EXISTS add_column_if_missing;

INSERT INTO roles (id, code, name, data_scope, status, remark) VALUES
(1, 'super_admin', '超级管理员', 'all', 'active', '拥有全部菜单、按钮、接口、数据和字段权限'),
(2, 'boss', '老板/管理层', 'all', 'active', '查看全局业务数据、报表和敏感金额'),
(3, 'sales_manager', '销售主管', 'team', 'active', '管理团队客户、项目、报价和销售订单'),
(4, 'sales', '销售人员', 'self', 'active', '管理本人客户、项目、报价和销售订单'),
(5, 'purchase_manager', '采购主管', 'all', 'active', '管理采购、供应商和应付业务'),
(6, 'purchase', '采购人员', 'self', 'active', '创建和跟进本人采购订单'),
(7, 'warehouse_manager', '仓库主管', 'all', 'active', '管理库存、入库、出库和SN'),
(8, 'warehouse', '仓库人员', 'all', 'active', '执行入库、出库和SN操作'),
(9, 'finance', '财务人员', 'all', 'active', '管理应收、应付、收款和付款'),
(10, 'aftersales', '售后人员', 'self', 'active', '处理售后工单和质保查询'),
(11, 'product_admin', '产品资料管理员', 'all', 'active', '维护商品、SKU、品牌和价格资料'),
(12, 'auditor', '只读审计员', 'all', 'active', '只读查看业务数据和操作日志')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
data_scope = VALUES(data_scope),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:user:list', '用户列表', 'api', 'system', '/api/v1/system/users', 'GET', 101, 'active'),
('system:user:create', '新增用户', 'api', 'system', '/api/v1/system/users', 'POST', 102, 'active'),
('system:user:update', '编辑用户', 'api', 'system', '/api/v1/system/users/:id', 'PUT', 103, 'active'),
('system:user:delete', '删除用户', 'api', 'system', '/api/v1/system/users/:id', 'DELETE', 104, 'active'),
('system:user:resetPassword', '重置密码', 'button', 'system', '', '', 105, 'active'),
('system:role:list', '角色列表', 'api', 'system', '/api/v1/system/roles', 'GET', 111, 'active'),
('system:role:create', '新增角色', 'api', 'system', '/api/v1/system/roles', 'POST', 112, 'active'),
('system:role:update', '编辑角色', 'api', 'system', '/api/v1/system/roles/:id', 'PUT', 113, 'active'),
('system:role:delete', '删除角色', 'api', 'system', '/api/v1/system/roles/:id', 'DELETE', 114, 'active'),
('system:role:assignPermission', '分配角色权限', 'button', 'system', '', '', 115, 'active'),
('system:permission:list', '权限列表', 'api', 'system', '/api/v1/system/permissions', 'GET', 116, 'active'),
('system:menu:list', '菜单列表', 'api', 'system', '/api/v1/system/menus', 'GET', 121, 'active'),
('system:menu:create', '新增菜单', 'api', 'system', '/api/v1/system/menus', 'POST', 122, 'active'),
('system:menu:update', '编辑菜单', 'api', 'system', '/api/v1/system/menus/:id', 'PUT', 123, 'active'),
('system:menu:delete', '删除菜单', 'api', 'system', '/api/v1/system/menus/:id', 'DELETE', 124, 'active'),
('system:dict:list', '字典列表', 'api', 'system', '/api/v1/system/dicts', 'GET', 131, 'active'),
('system:dict:create', '新增字典', 'api', 'system', '/api/v1/system/dicts', 'POST', 132, 'active'),
('system:dict:update', '编辑字典', 'api', 'system', '/api/v1/system/dicts/:id', 'PUT', 133, 'active'),
('system:dict:delete', '删除字典', 'api', 'system', '/api/v1/system/dicts/:id', 'DELETE', 134, 'active'),
('system:number-rule:list', '编号规则列表', 'api', 'system', '/api/v1/system/number-rules', 'GET', 141, 'active'),
('system:number-rule:create', '新增编号规则', 'api', 'system', '/api/v1/system/number-rules', 'POST', 142, 'active'),
('system:number-rule:update', '编辑编号规则', 'api', 'system', '/api/v1/system/number-rules/:id', 'PUT', 143, 'active'),
('system:number-rule:delete', '删除编号规则', 'api', 'system', '/api/v1/system/number-rules/:id', 'DELETE', 144, 'active'),
('system:numberRule:list', '编号规则列表(兼容)', 'api', 'system', '/api/v1/system/number-rules', 'GET', 145, 'active'),
('system:numberRule:update', '编辑编号规则(兼容)', 'api', 'system', '/api/v1/system/number-rules/:id', 'PUT', 146, 'active'),
('system:operation-log:list', '操作日志列表', 'api', 'system', '/api/v1/system/operation-logs', 'GET', 151, 'active'),
('system:log:list', '操作日志列表(兼容)', 'api', 'system', '/api/v1/system/operation-logs', 'GET', 152, 'active'),
('system:log:export', '导出操作日志', 'button', 'system', '', '', 153, 'active'),

('customer:list', '客户列表', 'api', 'customer', '/api/v1/customers', 'GET', 201, 'active'),
('customer:create', '新增客户', 'api', 'customer', '/api/v1/customers', 'POST', 202, 'active'),
('customer:update', '编辑客户', 'api', 'customer', '/api/v1/customers/:id', 'PUT', 203, 'active'),
('customer:delete', '删除客户', 'api', 'customer', '/api/v1/customers/:id', 'DELETE', 204, 'active'),
('customer:enable', '启用客户', 'button', 'customer', '', '', 205, 'active'),
('customer:disable', '停用客户', 'button', 'customer', '', '', 206, 'active'),
('customer:export', '导出客户', 'button', 'customer', '', '', 207, 'active'),
('customer:import', '导入客户', 'button', 'customer', '', '', 208, 'active'),

('supplier:list', '供应商列表', 'api', 'supplier', '/api/v1/suppliers', 'GET', 301, 'active'),
('supplier:create', '新增供应商', 'api', 'supplier', '/api/v1/suppliers', 'POST', 302, 'active'),
('supplier:update', '编辑供应商', 'api', 'supplier', '/api/v1/suppliers/:id', 'PUT', 303, 'active'),
('supplier:delete', '删除供应商', 'api', 'supplier', '/api/v1/suppliers/:id', 'DELETE', 304, 'active'),
('supplier:enable', '启用供应商', 'button', 'supplier', '', '', 305, 'active'),
('supplier:disable', '停用供应商', 'button', 'supplier', '', '', 306, 'active'),
('supplier:export', '导出供应商', 'button', 'supplier', '', '', 307, 'active'),
('supplier:import', '导入供应商', 'button', 'supplier', '', '', 308, 'active'),

('product:list', '商品列表', 'api', 'product', '/api/v1/products', 'GET', 401, 'active'),
('product:create', '新增商品', 'api', 'product', '/api/v1/products', 'POST', 402, 'active'),
('product:update', '编辑商品', 'api', 'product', '/api/v1/products/:id', 'PUT', 403, 'active'),
('product:delete', '删除商品', 'api', 'product', '/api/v1/products/:id', 'DELETE', 404, 'active'),
('product:enable', '启用商品', 'button', 'product', '', '', 405, 'active'),
('product:disable', '停用商品', 'button', 'product', '', '', 406, 'active'),
('product:export', '导出商品', 'button', 'product', '', '', 407, 'active'),
('product:import', '导入商品', 'button', 'product', '', '', 408, 'active'),
('sku:list', 'SKU列表', 'api', 'sku', '/api/v1/skus', 'GET', 421, 'active'),
('sku:create', '新增SKU', 'api', 'sku', '/api/v1/skus', 'POST', 422, 'active'),
('sku:update', '编辑SKU', 'api', 'sku', '/api/v1/skus/:id', 'PUT', 423, 'active'),
('sku:delete', '删除SKU', 'api', 'sku', '/api/v1/skus/:id', 'DELETE', 424, 'active'),
('sku:enable', '启用SKU', 'button', 'sku', '', '', 425, 'active'),
('sku:disable', '停用SKU', 'button', 'sku', '', '', 426, 'active'),
('sku:viewCost', '查看SKU成本', 'button', 'sku', '', '', 427, 'active'),
('sku:updateCost', '维护SKU成本', 'button', 'sku', '', '', 428, 'active'),
('sku:export', '导出SKU', 'button', 'sku', '', '', 429, 'active'),
('sku:import', '导入SKU', 'button', 'sku', '', '', 430, 'active'),

('warehouse:list', '仓库列表', 'api', 'warehouse', '/api/v1/warehouses', 'GET', 501, 'active'),
('warehouse:create', '新增仓库', 'api', 'warehouse', '/api/v1/warehouses', 'POST', 502, 'active'),
('warehouse:update', '编辑仓库', 'api', 'warehouse', '/api/v1/warehouses/:id', 'PUT', 503, 'active'),
('warehouse:delete', '删除仓库', 'api', 'warehouse', '/api/v1/warehouses/:id', 'DELETE', 504, 'active'),
('warehouse:enable', '启用仓库', 'button', 'warehouse', '', '', 505, 'active'),
('warehouse:disable', '停用仓库', 'button', 'warehouse', '', '', 506, 'active'),
('warehouse:export', '导出仓库', 'button', 'warehouse', '', '', 507, 'active'),
('warehouse:import', '导入仓库', 'button', 'warehouse', '', '', 508, 'active'),

('project:list', '项目列表', 'api', 'project', '/api/v1/projects', 'GET', 601, 'active'),
('project:create', '新增项目', 'api', 'project', '/api/v1/projects', 'POST', 602, 'active'),
('project:update', '编辑项目', 'api', 'project', '/api/v1/projects/:id', 'PUT', 603, 'active'),
('project:delete', '删除项目', 'api', 'project', '/api/v1/projects/:id', 'DELETE', 604, 'active'),
('project:follow', '项目跟进', 'button', 'project', '', '', 605, 'active'),
('project:close', '关闭项目', 'button', 'project', '', '', 606, 'active'),
('project:export', '导出项目', 'button', 'project', '', '', 607, 'active'),

('quotation:list', '报价单列表', 'api', 'quotation', '/api/v1/quotations', 'GET', 701, 'active'),
('quotation:create', '新增报价单', 'api', 'quotation', '/api/v1/quotations', 'POST', 702, 'active'),
('quotation:update', '编辑报价单', 'api', 'quotation', '/api/v1/quotations/:id', 'PUT', 703, 'active'),
('quotation:delete', '删除报价单', 'button', 'quotation', '', '', 704, 'active'),
('quotation:submit', '提交报价单', 'api', 'quotation', '/api/v1/quotations/:id/submit', 'POST', 705, 'active'),
('quotation:audit', '审核报价单', 'api', 'quotation', '/api/v1/quotations/:id/audit', 'POST', 706, 'active'),
('quotation:reject', '驳回报价单', 'api', 'quotation', '/api/v1/quotations/:id/reject', 'POST', 707, 'active'),
('quotation:unaudit', '反审核报价单', 'api', 'quotation', '/api/v1/quotations/:id/unaudit', 'POST', 708, 'active'),
('quotation:confirm', '客户确认报价单', 'api', 'quotation', '/api/v1/quotations/:id/confirm', 'POST', 709, 'active'),
('quotation:convert', '报价转销售订单', 'api', 'quotation', '/api/v1/quotations/:id/convert-to-sales-order', 'POST', 710, 'active'),
('quotation:cancel', '作废报价单', 'api', 'quotation', '/api/v1/quotations/:id/cancel', 'POST', 711, 'active'),
('quotation:copy', '复制报价单', 'button', 'quotation', '', '', 712, 'active'),
('quotation:export', '导出报价单', 'api', 'quotation', '/api/v1/quotations/:id/export', 'GET', 713, 'active'),
('quotation:print', '打印报价单', 'button', 'quotation', '', '', 714, 'active'),
('quotation:viewCost', '查看报价成本', 'button', 'quotation', '', '', 715, 'active'),
('quotation:viewProfit', '查看报价毛利', 'button', 'quotation', '', '', 716, 'active'),
('quotation:attachment', '报价附件', 'button', 'quotation', '', '', 717, 'active'),
('quotation:uploadAttachment', '上传报价附件', 'button', 'quotation', '', '', 718, 'active'),
('quotation:log', '报价日志', 'button', 'quotation', '', '', 719, 'active'),
('quotation:viewLog', '查看报价日志', 'button', 'quotation', '', '', 720, 'active'),

('sales:list', '销售订单列表', 'api', 'sales', '/api/v1/sales-orders', 'GET', 801, 'active'),
('sales:create', '新增销售订单', 'api', 'sales', '/api/v1/sales-orders', 'POST', 802, 'active'),
('sales:update', '编辑销售订单', 'api', 'sales', '/api/v1/sales-orders/:id', 'PUT', 803, 'active'),
('sales:delete', '删除销售订单', 'button', 'sales', '', '', 804, 'active'),
('sales:submit', '提交销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/submit', 'POST', 805, 'active'),
('sales:audit', '审核销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/audit', 'POST', 806, 'active'),
('sales:reject', '驳回销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/reject', 'POST', 807, 'active'),
('sales:unaudit', '反审核销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/unaudit', 'POST', 808, 'active'),
('sales:confirm', '确认销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/confirm', 'POST', 809, 'active'),
('sales:checkStock', '库存检查', 'api', 'sales', '/api/v1/sales-orders/:id/stock-check', 'GET', 810, 'active'),
('sales:generatePurchase', '生成采购', 'api', 'sales', '/api/v1/sales-orders/:id/create-shortage-purchase', 'POST', 811, 'active'),
('sales:outbound', '销售出库', 'api', 'sales', '/api/v1/sales-orders/:id/create-outbound', 'POST', 812, 'active'),
('sales:cancel', '取消销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/cancel', 'POST', 813, 'active'),
('sales:complete', '完成销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/complete', 'POST', 814, 'active'),
('sales:export', '导出销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/export', 'GET', 815, 'active'),
('sales:print', '打印销售订单', 'button', 'sales', '', '', 816, 'active'),
('sales:viewCost', '查看销售成本', 'button', 'sales', '', '', 817, 'active'),
('sales:viewProfit', '查看销售毛利', 'button', 'sales', '', '', 818, 'active'),
('sales:attachment', '销售附件', 'button', 'sales', '', '', 819, 'active'),
('sales:uploadAttachment', '上传销售附件', 'button', 'sales', '', '', 820, 'active'),
('sales:log', '销售日志', 'button', 'sales', '', '', 821, 'active'),
('sales:viewLog', '查看销售日志', 'button', 'sales', '', '', 822, 'active'),

('purchase:list', '采购订单列表', 'api', 'purchase', '/api/v1/purchase-orders', 'GET', 901, 'active'),
('purchase:create', '新增采购订单', 'api', 'purchase', '/api/v1/purchase-orders', 'POST', 902, 'active'),
('purchase:update', '编辑采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id', 'PUT', 903, 'active'),
('purchase:delete', '删除采购订单', 'button', 'purchase', '', '', 904, 'active'),
('purchase:submit', '提交采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/submit', 'POST', 905, 'active'),
('purchase:audit', '审核采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/audit', 'POST', 906, 'active'),
('purchase:reject', '驳回采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/reject', 'POST', 907, 'active'),
('purchase:unaudit', '反审核采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/unaudit', 'POST', 908, 'active'),
('purchase:confirm', '确认采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/confirm', 'POST', 909, 'active'),
('purchase:inbound', '采购入库', 'api', 'purchase', '/api/v1/purchase-orders/:id/create-inbound', 'POST', 910, 'active'),
('purchase:cancel', '取消采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/cancel', 'POST', 911, 'active'),
('purchase:complete', '完成采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/complete', 'POST', 912, 'active'),
('purchase:export', '导出采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/export', 'GET', 913, 'active'),
('purchase:print', '打印采购订单', 'button', 'purchase', '', '', 914, 'active'),
('purchase:viewPrice', '查看采购价', 'button', 'purchase', '', '', 915, 'active'),
('purchase:attachment', '采购附件', 'button', 'purchase', '', '', 916, 'active'),
('purchase:uploadAttachment', '上传采购附件', 'button', 'purchase', '', '', 917, 'active'),
('purchase:log', '采购日志', 'button', 'purchase', '', '', 918, 'active'),
('purchase:viewLog', '查看采购日志', 'button', 'purchase', '', '', 919, 'active'),

('inventory:stock:list', '库存现存量列表', 'api', 'inventory', '/api/v1/inventory/stocks', 'GET', 1001, 'active'),
('inventory:stock:viewAmount', '查看库存金额', 'field', 'inventory', '', '', 1002, 'active'),
('inventory:stock:export', '导出库存', 'button', 'inventory', '', '', 1003, 'active'),
('inventory:record:list', '库存流水列表', 'api', 'inventory', '/api/v1/inventory/records', 'GET', 1011, 'active'),
('inventory:record:export', '导出库存流水', 'button', 'inventory', '', '', 1012, 'active'),
('inventory:inbound:list', '入库单列表', 'api', 'inventory', '/api/v1/inventory/inbound-orders', 'GET', 1021, 'active'),
('inventory:inbound:create', '新增入库单', 'api', 'inventory', '/api/v1/inventory/inbound-orders', 'POST', 1022, 'active'),
('inventory:inbound:update', '编辑入库单', 'button', 'inventory', '', '', 1023, 'active'),
('inventory:inbound:confirm', '确认入库', 'api', 'inventory', '/api/v1/inventory/inbound-orders/:id/confirm', 'POST', 1024, 'active'),
('inventory:inbound:cancel', '取消入库单', 'button', 'inventory', '', '', 1025, 'active'),
('inventory:inbound:print', '打印入库单', 'button', 'inventory', '', '', 1026, 'active'),
('inventory:outbound:list', '出库单列表', 'api', 'inventory', '/api/v1/inventory/outbound-orders', 'GET', 1031, 'active'),
('inventory:outbound:create', '新增出库单', 'api', 'inventory', '/api/v1/inventory/outbound-orders', 'POST', 1032, 'active'),
('inventory:outbound:update', '编辑出库单', 'button', 'inventory', '', '', 1033, 'active'),
('inventory:outbound:confirm', '确认出库', 'api', 'inventory', '/api/v1/inventory/outbound-orders/:id/confirm', 'POST', 1034, 'active'),
('inventory:outbound:cancel', '取消出库单', 'button', 'inventory', '', '', 1035, 'active'),
('inventory:outbound:print', '打印出库单', 'button', 'inventory', '', '', 1036, 'active'),
('inventory:export', '导出库存(兼容)', 'button', 'inventory', '', '', 1041, 'active'),

('serial:list', 'SN列表', 'api', 'serial', '/api/v1/serials', 'GET', 1101, 'active'),
('serial:detail', 'SN详情', 'api', 'serial', '/api/v1/serials/:id', 'GET', 1102, 'active'),
('serial:lifecycle', 'SN流转记录', 'button', 'serial', '', '', 1103, 'active'),
('serial:create', '新增SN', 'button', 'serial', '', '', 1104, 'active'),
('serial:update', '编辑SN', 'button', 'serial', '', '', 1105, 'active'),
('serial:export', '导出SN', 'button', 'serial', '', '', 1106, 'active'),
('serial:import', '导入SN', 'button', 'serial', '', '', 1107, 'active'),
('serial:changeStatus', '变更SN状态', 'button', 'serial', '', '', 1108, 'active'),
('serial:viewCustomer', '查看SN客户', 'field', 'serial', '', '', 1109, 'active'),
('serial:viewSalesOrder', '查看SN销售订单', 'field', 'serial', '', '', 1110, 'active'),
('serial:viewWarranty', '查看SN质保', 'field', 'serial', '', '', 1111, 'active'),
('serial:select', '选择SN', 'button', 'serial', '', '', 1112, 'active'),
('serial:scan', '扫码SN', 'button', 'serial', '', '', 1113, 'active'),

('contract:list', '合同列表', 'api', 'contract', '/api/v1/contracts', 'GET', 1201, 'active'),
('contract:create', '新增合同', 'api', 'contract', '/api/v1/contracts', 'POST', 1202, 'active'),
('contract:update', '编辑合同', 'api', 'contract', '/api/v1/contracts/:id', 'PUT', 1203, 'active'),
('contract:cancel', '作废合同', 'api', 'contract', '/api/v1/contracts/:id/cancel', 'POST', 1204, 'active'),
('contract:sign', '签署合同', 'api', 'contract', '/api/v1/contracts/:id/sign', 'POST', 1205, 'active'),
('contract:complete', '完成合同', 'api', 'contract', '/api/v1/contracts/:id/complete', 'POST', 1206, 'active'),
('contract:upload', '上传合同附件', 'api', 'contract', '/api/v1/contracts/:id/files', 'POST', 1207, 'active'),
('contract:download', '下载合同附件', 'api', 'contract', '/api/v1/contracts/files/:fileId/download', 'GET', 1208, 'active'),
('contract:deleteFile', '删除合同附件', 'api', 'contract', '/api/v1/contracts/files/:fileId', 'DELETE', 1209, 'active'),
('contract:delete', '删除合同(兼容)', 'api', 'contract', '/api/v1/contracts/files/:fileId', 'DELETE', 1210, 'active'),
('contract:viewAmount', '查看合同金额', 'field', 'contract', '', '', 1211, 'active'),
('contract:viewLog', '查看合同日志', 'button', 'contract', '', '', 1212, 'active'),
('contract:print', '打印合同', 'button', 'contract', '', '', 1213, 'active'),
('contract:log', '合同日志(兼容)', 'button', 'contract', '', '', 1214, 'active'),
('contract:template:list', '合同模板列表', 'api', 'contract', '/api/v1/contract-templates', 'GET', 1221, 'active'),
('contract:template:create', '新增合同模板', 'api', 'contract', '/api/v1/contract-templates', 'POST', 1222, 'active'),
('contract:template:update', '编辑合同模板', 'api', 'contract', '/api/v1/contract-templates/:id', 'PUT', 1223, 'active'),
('contract:template:delete', '删除合同模板', 'api', 'contract', '/api/v1/contract-templates/:id', 'DELETE', 1224, 'active'),
('contract:template:upload', '上传合同模板', 'button', 'contract', '', '', 1225, 'active'),
('contract:template:download', '下载合同模板', 'api', 'contract', '/api/v1/contract-templates/:id/download', 'GET', 1226, 'active'),
('contract:template:enable', '启用合同模板', 'button', 'contract', '', '', 1227, 'active'),
('contract:template:disable', '停用合同模板', 'button', 'contract', '', '', 1228, 'active'),
('contract:template:setDefault', '设置默认合同模板', 'button', 'contract', '', '', 1229, 'active'),

('finance:receivable:list', '应收列表', 'api', 'finance', '/api/v1/finance/receivables', 'GET', 1301, 'active'),
('finance:receivable:detail', '应收详情', 'button', 'finance', '', '', 1302, 'active'),
('finance:receivable:export', '导出应收', 'button', 'finance', '', '', 1303, 'active'),
('finance:receipt:list', '收款列表', 'api', 'finance', '/api/v1/finance/receipts', 'GET', 1311, 'active'),
('finance:receipt:create', '新增收款', 'api', 'finance', '/api/v1/finance/receipts', 'POST', 1312, 'active'),
('finance:receipt:cancel', '反冲收款', 'button', 'finance', '', '', 1313, 'active'),
('finance:receipt:export', '导出收款', 'button', 'finance', '', '', 1314, 'active'),
('finance:payable:list', '应付列表', 'api', 'finance', '/api/v1/finance/payables', 'GET', 1321, 'active'),
('finance:payable:detail', '应付详情', 'button', 'finance', '', '', 1322, 'active'),
('finance:payable:export', '导出应付', 'button', 'finance', '', '', 1323, 'active'),
('finance:payment:list', '付款列表', 'api', 'finance', '/api/v1/finance/payments', 'GET', 1331, 'active'),
('finance:payment:create', '新增付款', 'api', 'finance', '/api/v1/finance/payments', 'POST', 1332, 'active'),
('finance:payment:cancel', '反冲付款', 'button', 'finance', '', '', 1333, 'active'),
('finance:payment:export', '导出付款', 'button', 'finance', '', '', 1334, 'active'),
('finance:viewAmount', '查看财务金额', 'field', 'finance', '', '', 1341, 'active'),
('finance:list', '财务总览(兼容)', 'api', 'finance', '/api/v1/finance', 'GET', 1342, 'active'),
('finance:export', '导出财务(兼容)', 'button', 'finance', '', '', 1343, 'active'),
('finance:log', '财务日志(兼容)', 'button', 'finance', '', '', 1344, 'active'),
('finance:writeoff', '财务核销(兼容)', 'button', 'finance', '', '', 1345, 'active'),

('aftersales:ticket:list', '售后工单列表', 'api', 'aftersales', '/api/v1/aftersales', 'GET', 1401, 'active'),
('aftersales:ticket:create', '新增售后工单', 'api', 'aftersales', '/api/v1/aftersales', 'POST', 1402, 'active'),
('aftersales:ticket:update', '编辑售后工单', 'api', 'aftersales', '/api/v1/aftersales/:id', 'PUT', 1403, 'active'),
('aftersales:ticket:process', '处理售后工单', 'button', 'aftersales', '', '', 1404, 'active'),
('aftersales:ticket:close', '关闭售后工单', 'button', 'aftersales', '', '', 1405, 'active'),
('aftersales:ticket:cancel', '取消售后工单', 'button', 'aftersales', '', '', 1406, 'active'),
('aftersales:ticket:export', '导出售后工单', 'button', 'aftersales', '', '', 1407, 'active'),
('aftersales:warranty:search', '质保查询', 'api', 'aftersales', '/api/v1/aftersales/warranty', 'GET', 1411, 'active'),
('aftersales:warranty:export', '导出质保', 'button', 'aftersales', '', '', 1412, 'active'),
('aftersales:viewCustomer', '查看售后客户', 'field', 'aftersales', '', '', 1413, 'active'),
('aftersales:viewSN', '查看售后SN', 'field', 'aftersales', '', '', 1414, 'active'),
('aftersales:list', '售后列表(兼容)', 'api', 'aftersales', '/api/v1/aftersales', 'GET', 1415, 'active'),
('aftersales:create', '新增售后(兼容)', 'api', 'aftersales', '/api/v1/aftersales', 'POST', 1416, 'active'),
('aftersales:update', '编辑售后(兼容)', 'api', 'aftersales', '/api/v1/aftersales/:id', 'PUT', 1417, 'active'),
('aftersales:cancel', '取消售后(兼容)', 'button', 'aftersales', '', '', 1418, 'active'),
('aftersales:complete', '完成售后(兼容)', 'button', 'aftersales', '', '', 1419, 'active'),
('aftersales:export', '导出售后(兼容)', 'button', 'aftersales', '', '', 1420, 'active'),
('aftersales:print', '打印售后(兼容)', 'button', 'aftersales', '', '', 1421, 'active'),
('aftersales:attachment', '售后附件(兼容)', 'button', 'aftersales', '', '', 1422, 'active'),
('aftersales:log', '售后日志(兼容)', 'button', 'aftersales', '', '', 1423, 'active'),

('report:sales:view', '销售报表查看', 'api', 'report', '/api/v1/reports/sales', 'GET', 1501, 'active'),
('report:sales:export', '销售报表导出', 'button', 'report', '', '', 1502, 'active'),
('report:purchase:view', '采购报表查看', 'api', 'report', '/api/v1/reports/purchase', 'GET', 1511, 'active'),
('report:purchase:export', '采购报表导出', 'button', 'report', '', '', 1512, 'active'),
('report:inventory:view', '库存报表查看', 'api', 'report', '/api/v1/reports/inventory', 'GET', 1521, 'active'),
('report:inventory:export', '库存报表导出', 'button', 'report', '', '', 1522, 'active'),
('report:finance:view', '财务报表查看', 'api', 'report', '/api/v1/reports/finance', 'GET', 1531, 'active'),
('report:finance:export', '财务报表导出', 'button', 'report', '', '', 1532, 'active'),
('report:aftersales:view', '售后报表查看', 'api', 'report', '/api/v1/reports/aftersales', 'GET', 1541, 'active'),
('report:aftersales:export', '售后报表导出', 'button', 'report', '', '', 1542, 'active'),
('dashboard:view', '工作台查看', 'api', 'dashboard', '/api/v1/dashboard', 'GET', 1551, 'active'),
('report:view', '报表查看(兼容)', 'api', 'report', '/api/v1/reports', 'GET', 1552, 'active'),
('report:sales', '销售报表(兼容)', 'api', 'report', '/api/v1/reports/sales', 'GET', 1553, 'active'),
('report:purchase', '采购报表(兼容)', 'api', 'report', '/api/v1/reports/purchase', 'GET', 1554, 'active'),
('report:inventory', '库存报表(兼容)', 'api', 'report', '/api/v1/reports/inventory', 'GET', 1555, 'active'),
('report:aftersales', '售后报表(兼容)', 'api', 'report', '/api/v1/reports/aftersales', 'GET', 1556, 'active'),

('field:cost_price:view', '查看成本价', 'field', 'field', '', '', 2001, 'active'),
('field:purchase_price:view', '查看采购价', 'field', 'field', '', '', 2002, 'active'),
('field:gross_profit:view', '查看毛利', 'field', 'field', '', '', 2003, 'active'),
('field:gross_margin:view', '查看毛利率', 'field', 'field', '', '', 2004, 'active'),
('field:stock_amount:view', '查看库存金额', 'field', 'field', '', '', 2005, 'active'),
('field:receivable_amount:view', '查看应收金额', 'field', 'field', '', '', 2006, 'active'),
('field:payable_amount:view', '查看应付金额', 'field', 'field', '', '', 2007, 'active'),
('field:customer_credit:view', '查看客户信用额度', 'field', 'field', '', '', 2008, 'active'),
('field:supplier_settlement:view', '查看供应商结算信息', 'field', 'field', '', '', 2009, 'active'),
('field:sensitive_export', '导出敏感数据', 'field', 'field', '', '', 2010, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','suppliers','products','skus','projects','quotations','salesOrders','purchaseOrders','stocks','inventoryRecords','serialNumbers','contract','contractTemplates','contractList','contractFiles','finance','receivables','payables','receipts','payments','reports','salesReport','purchaseReport','inventoryReport','aftersalesReport','systemOperationLogs')
WHERE r.code = 'boss';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('system','masterData','sales','purchase','inventory','contract','finance','reports')
WHERE r.code = 'boss';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','projects','quotations','salesOrders','contract','contractList','aftersales','warrantySearch')
WHERE r.code IN ('sales_manager','sales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','sales','contract','aftersales')
WHERE r.code IN ('sales_manager','sales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('suppliers','products','skus','purchase','purchaseOrders','contract','contractList','finance','payables')
WHERE r.code IN ('purchase_manager','purchase');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','purchase','contract','finance')
WHERE r.code IN ('purchase_manager','purchase');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('inventory','stocks','inboundOrders','outboundOrders','inventoryRecords','serialNumbers','salesOrders','purchaseOrders')
WHERE r.code IN ('warehouse_manager','warehouse');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('sales','purchase','inventory')
WHERE r.code IN ('warehouse_manager','warehouse');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('salesOrders','purchaseOrders','contract','contractList','finance','receivables','payables','receipts','payments','reports','salesReport','purchaseReport')
WHERE r.code = 'finance';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('sales','purchase','contract','finance','reports')
WHERE r.code = 'finance';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersales','aftersalesTickets','warrantySearch','serialNumbers','customers','salesOrders')
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','sales','inventory','aftersales')
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('products','skus','suppliers')
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData')
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','suppliers','products','skus','projects','quotations','salesOrders','purchaseOrders','stocks','inventoryRecords','serialNumbers','contract','contractList','finance','receivables','payables','aftersales','aftersalesTickets','reports','salesReport','purchaseReport','inventoryReport','aftersalesReport','systemOperationLogs')
WHERE r.code = 'auditor';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('system','masterData','sales','purchase','inventory','contract','finance','aftersales','reports')
WHERE r.code = 'auditor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'dashboard:view','customer:list','supplier:list','product:list','sku:list','project:list',
    'quotation:list','quotation:viewCost','quotation:viewProfit',
    'sales:list','sales:viewCost','sales:viewProfit',
    'purchase:list','purchase:viewPrice',
    'inventory:stock:list','inventory:stock:viewAmount','inventory:record:list',
    'contract:list','contract:viewAmount','contract:download',
    'finance:receivable:list','finance:payable:list','finance:receipt:list','finance:payment:list','finance:viewAmount',
    'report:sales:view','report:purchase:view','report:inventory:view','report:finance:view','report:aftersales:view',
    'field:cost_price:view','field:purchase_price:view','field:gross_profit:view','field:gross_margin:view',
    'field:stock_amount:view','field:receivable_amount:view','field:payable_amount:view','field:sensitive_export'
)
WHERE r.code = 'boss';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','customer:create','customer:update',
    'project:list','project:create','project:update','project:follow',
    'quotation:list','quotation:create','quotation:update','quotation:submit','quotation:confirm','quotation:convert','quotation:copy','quotation:export','quotation:print','quotation:viewProfit',
    'sales:list','sales:create','sales:update','sales:submit','sales:confirm','sales:checkStock','sales:generatePurchase','sales:export','sales:print','sales:viewProfit',
    'contract:list','contract:create','contract:upload','contract:download',
    'finance:receivable:list','aftersales:warranty:search','field:gross_profit:view','field:gross_margin:view'
)
WHERE r.code = 'sales_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','customer:create','customer:update',
    'project:list','project:create','project:update',
    'quotation:list','quotation:create','quotation:update','quotation:submit','quotation:copy','quotation:export','quotation:print',
    'sales:list','sales:create','sales:update','sales:submit','sales:checkStock',
    'contract:list','contract:create','contract:upload','contract:download',
    'aftersales:warranty:search'
)
WHERE r.code = 'sales';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'supplier:list','supplier:create','supplier:update',
    'product:list','sku:list','sku:viewCost',
    'purchase:list','purchase:create','purchase:update','purchase:submit','purchase:audit','purchase:reject','purchase:unaudit','purchase:confirm','purchase:cancel','purchase:export','purchase:print','purchase:viewPrice',
    'contract:list','contract:create','contract:upload','contract:download',
    'finance:payable:list','report:purchase:view','field:purchase_price:view'
)
WHERE r.code = 'purchase_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'supplier:list','supplier:create','supplier:update',
    'product:list','sku:list',
    'purchase:list','purchase:create','purchase:update','purchase:submit','purchase:export','purchase:print','purchase:viewPrice',
    'contract:list','contract:create','contract:upload','contract:download',
    'field:purchase_price:view'
)
WHERE r.code = 'purchase';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:list','inventory:stock:viewAmount','inventory:record:list',
    'inventory:inbound:list','inventory:inbound:create','inventory:inbound:update','inventory:inbound:confirm','inventory:inbound:cancel','inventory:inbound:print',
    'inventory:outbound:list','inventory:outbound:create','inventory:outbound:update','inventory:outbound:confirm','inventory:outbound:cancel','inventory:outbound:print',
    'serial:list','serial:detail','serial:lifecycle','serial:create','serial:update','serial:changeStatus','serial:export',
    'purchase:list','sales:list','field:stock_amount:view'
)
WHERE r.code = 'warehouse_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:list','inventory:record:list',
    'inventory:inbound:list','inventory:inbound:create','inventory:inbound:confirm',
    'inventory:outbound:list','inventory:outbound:create','inventory:outbound:confirm',
    'serial:list','serial:detail','serial:lifecycle','serial:create','serial:update'
)
WHERE r.code = 'warehouse';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','supplier:list','sales:list','purchase:list',
    'contract:list','contract:viewAmount','contract:download',
    'finance:receivable:list','finance:receivable:detail','finance:receipt:list','finance:receipt:create','finance:receipt:cancel',
    'finance:payable:list','finance:payable:detail','finance:payment:list','finance:payment:create','finance:payment:cancel',
    'finance:viewAmount','report:finance:view','report:sales:view','report:purchase:view',
    'field:receivable_amount:view','field:payable_amount:view'
)
WHERE r.code = 'finance';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:list','aftersales:ticket:create','aftersales:ticket:update','aftersales:ticket:process','aftersales:ticket:close','aftersales:warranty:search',
    'serial:list','serial:detail','serial:lifecycle','serial:viewCustomer','serial:viewSalesOrder','serial:viewWarranty',
    'customer:list','sales:list'
)
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'product:list','product:create','product:update','product:delete','product:enable','product:disable','product:import','product:export',
    'sku:list','sku:create','sku:update','sku:delete','sku:enable','sku:disable','sku:updateCost','sku:import','sku:export','sku:viewCost',
    'supplier:list','field:cost_price:view','field:purchase_price:view'
)
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operation-log:list','system:log:list',
    'customer:list','supplier:list','product:list','sku:list','project:list','quotation:list','sales:list','purchase:list',
    'inventory:stock:list','inventory:record:list','serial:list','contract:list',
    'finance:receivable:list','finance:payable:list','aftersales:ticket:list',
    'report:sales:view','report:purchase:view','report:inventory:view','report:finance:view'
)
WHERE r.code = 'auditor';


-- ============================================================================
-- Source: 009_system_foundation.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('users', 'phone', 'VARCHAR(30) NOT NULL DEFAULT '''' COMMENT ''手机号''', 'display_name');
CALL add_column_if_missing('users', 'email', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''邮箱''', 'phone');
CALL add_column_if_missing('users', 'organization_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''所属机构ID''', 'email');
CALL add_column_if_missing('users', 'position', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''岗位''', 'organization_id');
CALL add_column_if_missing('users', 'last_login_at', 'DATETIME NULL COMMENT ''最后登录时间''', 'status');

DROP PROCEDURE IF EXISTS add_column_if_missing;

CREATE TABLE IF NOT EXISTS system_orgs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    org_name VARCHAR(100) NOT NULL,
    org_full_name VARCHAR(200) NOT NULL DEFAULT '',
    org_code VARCHAR(64) NOT NULL DEFAULT '',
    org_type VARCHAR(32) NOT NULL DEFAULT 'department',
    leader_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    phone VARCHAR(30) NOT NULL DEFAULT '',
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_system_orgs_parent_id (parent_id),
    KEY idx_system_orgs_status (status),
    KEY idx_system_orgs_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS system_files (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL DEFAULT '',
    file_size BIGINT NOT NULL DEFAULT 0,
    content_type VARCHAR(100) NOT NULL DEFAULT '',
    storage_driver VARCHAR(32) NOT NULL DEFAULT 'local',
    business_type VARCHAR(64) NOT NULL DEFAULT '',
    business_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    deleted_at DATETIME NULL,
    KEY idx_system_files_name (file_name),
    KEY idx_system_files_biz (business_type, business_id),
    KEY idx_system_files_status (status),
    KEY idx_system_files_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS login_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL DEFAULT '',
    user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    nickname VARCHAR(128) NOT NULL DEFAULT '',
    ip VARCHAR(64) NOT NULL DEFAULT '',
    location VARCHAR(128) NOT NULL DEFAULT '',
    browser VARCHAR(128) NOT NULL DEFAULT '',
    os VARCHAR(128) NOT NULL DEFAULT '',
    device VARCHAR(128) NOT NULL DEFAULT '',
    login_type TINYINT NOT NULL DEFAULT 0 COMMENT '0成功 1失败 2退出 3token过期',
    status VARCHAR(32) NOT NULL DEFAULT 'success',
    failure_reason VARCHAR(255) NOT NULL DEFAULT '',
    user_agent VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_login_logs_username (username),
    KEY idx_login_logs_created_at (created_at),
    KEY idx_login_logs_status (status)
);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(49, 2, 'systemOrganizations', 'organization', '/system/organization/index', '', '机构管理', 'OfficeBuilding', 4),
(50, 2, 'systemFiles', 'files', '/system/file/index', '', '文件管理', 'FolderOpened', 6),
(51, 2, 'systemLoginLogs', 'login-record', '/system/login-record/index', '', '登录日志', 'Clock', 7)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (49, 50, 51)
WHERE r.code IN ('super_admin', 'boss', 'auditor');

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:org:list', '机构列表', 'api', 'system', '/api/v1/system/organization', 'GET', 161, 'active'),
('system:org:create', '新增机构', 'api', 'system', '/api/v1/system/organization', 'POST', 162, 'active'),
('system:org:update', '编辑机构', 'api', 'system', '/api/v1/system/organization', 'PUT', 163, 'active'),
('system:org:delete', '删除机构', 'api', 'system', '/api/v1/system/organization/:id', 'DELETE', 164, 'active'),
('system:org:tree', '机构树', 'api', 'system', '/api/v1/system/organization/tree', 'GET', 165, 'active'),
('system:file:list', '文件列表', 'api', 'system', '/api/v1/file/page', 'GET', 171, 'active'),
('system:file:upload', '上传文件', 'api', 'system', '/api/v1/file/upload', 'POST', 172, 'active'),
('system:file:download', '下载文件', 'api', 'system', '/api/v1/file/download/:id', 'GET', 173, 'active'),
('system:file:delete', '删除文件', 'api', 'system', '/api/v1/file/remove/:id', 'DELETE', 174, 'active'),
('system:loginLog:list', '登录日志列表', 'api', 'system', '/api/v1/system/login-record/page', 'GET', 181, 'active'),
('system:loginLog:delete', '删除登录日志', 'button', 'system', '', '', 182, 'active'),
('system:loginLog:clear', '清空登录日志', 'button', 'system', '', '', 183, 'active'),
('system:loginLog:export', '导出登录日志', 'button', 'system', '', '', 184, 'active'),
('system:role:assignDataScope', '分配数据范围', 'button', 'system', '', '', 185, 'active'),
('system:menu:tree', '菜单树', 'api', 'system', '/api/v1/system/menus/tree', 'GET', 186, 'active'),
('system:user:enable', '启用用户', 'button', 'system', '', '', 187, 'active'),
('system:user:disable', '停用用户', 'button', 'system', '', '', 188, 'active'),
('system:user:assignRole', '分配用户角色', 'button', 'system', '', '', 189, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:org:list','system:org:tree','system:file:list',
    'system:loginLog:list','system:operation-log:list','system:log:list'
)
WHERE r.code IN ('boss', 'auditor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:org:list','system:org:create','system:org:update','system:org:delete','system:org:tree',
    'system:file:list','system:file:upload','system:file:download','system:file:delete',
    'system:loginLog:list','system:loginLog:delete','system:loginLog:clear','system:loginLog:export',
    'system:role:assignDataScope','system:menu:tree',
    'system:user:enable','system:user:disable','system:user:assignRole'
)
WHERE r.code = 'super_admin';

INSERT INTO system_orgs (id, parent_id, org_name, org_full_name, org_code, org_type, sort, status, remark) VALUES
(1, 0, '总公司', '总公司', 'HQ', 'company', 1, 'active', '系统默认机构'),
(2, 1, '销售部', '总公司/销售部', 'SALES', 'department', 2, 'active', ''),
(3, 1, '采购部', '总公司/采购部', 'PURCHASE', 'department', 3, 'active', ''),
(4, 1, '仓储部', '总公司/仓储部', 'WAREHOUSE', 'department', 4, 'active', ''),
(5, 1, '财务部', '总公司/财务部', 'FINANCE', 'department', 5, 'active', ''),
(6, 1, '售后部', '总公司/售后部', 'AFTERSALES', 'department', 6, 'active', '')
ON DUPLICATE KEY UPDATE
org_name = VALUES(org_name),
org_full_name = VALUES(org_full_name),
org_code = VALUES(org_code),
org_type = VALUES(org_type),
sort = VALUES(sort),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:operationLog:delete', 'Delete operation logs', 'api', 'system', '/api/v1/system/operation-logs/:id', 'DELETE', 190, 'active'),
('system:operationLog:clear', 'Clear operation logs', 'api', 'system', '/api/v1/system/operation-logs/clear', 'POST', 191, 'active'),
('system:operationLog:export', 'Export operation logs', 'api', 'system', '/api/v1/system/operation-logs/export', 'GET', 192, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operationLog:delete','system:operationLog:clear','system:operationLog:export'
)
WHERE r.code = 'super_admin';


-- ============================================================================
-- Source: 010_go_live_foundation.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$
CREATE PROCEDURE add_column_if_missing(
    IN table_name_in VARCHAR(64),
    IN column_name_in VARCHAR(64),
    IN column_definition_in TEXT,
    IN after_column_in VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = table_name_in
          AND COLUMN_NAME = column_name_in
    ) THEN
        SET @sql = CONCAT(
            'ALTER TABLE `', table_name_in, '` ADD COLUMN `', column_name_in, '` ',
            column_definition_in,
            IF(after_column_in IS NULL OR after_column_in = '', '', CONCAT(' AFTER `', after_column_in, '`'))
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL add_column_if_missing('receipts', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active''', 'remark');
CALL add_column_if_missing('payments', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active''', 'remark');

CREATE TABLE IF NOT EXISTS messages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    recipient_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    title VARCHAR(200) NOT NULL,
    content VARCHAR(1000) NOT NULL DEFAULT '',
    message_type VARCHAR(32) NOT NULL DEFAULT 'notice',
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    route_path VARCHAR(255) NOT NULL DEFAULT '',
    is_todo TINYINT(1) NOT NULL DEFAULT 0,
    read_at DATETIME NULL,
    done_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_messages_recipient (recipient_id, read_at),
    KEY idx_messages_todo (recipient_id, is_todo, done_at),
    KEY idx_messages_biz (biz_type, biz_id),
    KEY idx_messages_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS import_tasks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    task_no VARCHAR(64) NOT NULL UNIQUE,
    biz_type VARCHAR(64) NOT NULL,
    file_name VARCHAR(255) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'previewed',
    total_rows INT NOT NULL DEFAULT 0,
    success_rows INT NOT NULL DEFAULT 0,
    failed_rows INT NOT NULL DEFAULT 0,
    payload LONGTEXT NULL,
    error_message VARCHAR(1000) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    confirmed_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    confirmed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_import_tasks_biz_type (biz_type),
    KEY idx_import_tasks_status (status),
    KEY idx_import_tasks_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS import_task_errors (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    task_id BIGINT UNSIGNED NOT NULL,
    row_no INT NOT NULL DEFAULT 0,
    field_name VARCHAR(64) NOT NULL DEFAULT '',
    message VARCHAR(500) NOT NULL,
    raw_data JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_import_task_errors_task_id (task_id)
);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(52, 0, 'messageCenter', '/messages', 'LAYOUT', '/messages/list', '消息中心', 'Message', 12),
(53, 52, 'myMessages', 'list', '/message/list/index', '', '我的消息', 'Message', 1),
(54, 52, 'myTodos', 'todos', '/message/todo/index', '', '我的待办', 'Bell', 2),
(55, 0, 'dataImport', '/import', 'LAYOUT', '/import/tasks', '数据导入', 'UploadFilled', 13),
(56, 55, 'importTasks', 'tasks', '/import/tasks/index', '', '导入任务', 'Upload', 1),
(57, 55, 'importLogs', 'logs', '/import/tasks/index', '', '导入日志', 'Tickets', 2)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('message:list', '查看消息', 'api', 'message', '/api/v1/messages', 'GET', 1601, 'active'),
('message:todo:list', '查看待办消息', 'api', 'message', '/api/v1/messages/todos', 'GET', 1602, 'active'),
('message:read', '标记消息已读', 'api', 'message', '/api/v1/messages/:id/read', 'POST', 1603, 'active'),
('message:todo:done', '完成待办消息', 'api', 'message', '/api/v1/messages/:id/done', 'POST', 1604, 'active'),
('message:delete', '删除消息', 'api', 'message', '/api/v1/messages/:id', 'DELETE', 1605, 'active'),
('import:template', 'Download import template', 'api', 'import', '/api/v1/import/templates/:bizType', 'GET', 1701, 'active'),
('import:preview', 'Preview import', 'api', 'import', '/api/v1/import/:bizType/preview', 'POST', 1702, 'active'),
('import:confirm', 'Confirm import', 'api', 'import', '/api/v1/import/:bizType/confirm', 'POST', 1703, 'active'),
('import:task:list', 'List import tasks', 'api', 'import', '/api/v1/import/tasks', 'GET', 1704, 'active'),
('import:task:detail', 'Import task detail', 'api', 'import', '/api/v1/import/tasks/:id', 'GET', 1705, 'active'),
('import:task:errors', 'Import task errors', 'api', 'import', '/api/v1/import/tasks/:id/errors', 'GET', 1706, 'active'),
('quotation:print', 'Print quotation', 'api', 'quotation', '/api/v1/quotations/:id/print', 'GET', 714, 'active'),
('quotation:copy', 'Copy quotation', 'api', 'quotation', '/api/v1/quotations/:id/copy', 'POST', 712, 'active'),
('quotation:delete', 'Delete quotation', 'api', 'quotation', '/api/v1/quotations/:id', 'DELETE', 704, 'active'),
('sales:print', 'Print sales order', 'api', 'sales', '/api/v1/sales-orders/:id/print', 'GET', 816, 'active'),
('sales:delete', 'Delete sales order', 'api', 'sales', '/api/v1/sales-orders/:id', 'DELETE', 804, 'active'),
('purchase:print', 'Print purchase order', 'api', 'purchase', '/api/v1/purchase-orders/:id/print', 'GET', 914, 'active'),
('purchase:delete', 'Delete purchase order', 'api', 'purchase', '/api/v1/purchase-orders/:id', 'DELETE', 904, 'active'),
('inventory:stock:export', 'Export stock', 'api', 'inventory', '/api/v1/inventory/stocks/export', 'GET', 1003, 'active'),
('inventory:record:export', 'Export inventory records', 'api', 'inventory', '/api/v1/inventory/records/export', 'GET', 1012, 'active'),
('inventory:inbound:print', 'Print inbound order', 'api', 'inventory', '/api/v1/inventory/inbound-orders/:id/print', 'GET', 1026, 'active'),
('inventory:outbound:print', 'Print outbound order', 'api', 'inventory', '/api/v1/inventory/outbound-orders/:id/print', 'GET', 1036, 'active'),
('serial:export', 'Export serial numbers', 'api', 'serial', '/api/v1/serial-numbers/export', 'GET', 1112, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('messageCenter','myMessages','myTodos')
WHERE r.code IN ('boss','sales_manager','sales','purchase_manager','purchase','warehouse_manager','warehouse','finance','aftersales','product_admin','auditor');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dataImport','importTasks','importLogs')
WHERE r.code IN ('super_admin','product_admin','warehouse_manager');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('message:list','message:todo:list','message:read','message:todo:done','message:delete')
WHERE r.code IN ('boss','sales_manager','sales','purchase_manager','purchase','warehouse_manager','warehouse','finance','aftersales','product_admin','auditor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('import:template','import:preview','import:confirm','import:task:list','import:task:detail','import:task:errors')
WHERE r.code IN ('super_admin','product_admin','warehouse_manager');

DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 011_go_live_route_alignment.sql
-- ============================================================================
INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:operationLog:detail', '操作日志详情', 'api', 'system', '/api/v1/system/operation-logs/:id', 'GET', 193, 'active'),
('system:role:enable', '启用角色', 'api', 'system', '/api/v1/system/roles/:id/enable', 'POST', 194, 'active'),
('system:role:disable', '停用角色', 'api', 'system', '/api/v1/system/roles/:id/disable', 'POST', 195, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

UPDATE permissions SET path = '/api/v1/system/roles/:id/assign-permissions', method = 'POST'
WHERE code = 'system:role:assignPermission';

UPDATE permissions SET path = '/api/v1/system/roles/:id/assign-data-scope', method = 'POST'
WHERE code = 'system:role:assignDataScope';

UPDATE permissions SET path = '/api/v1/system/orgs', method = 'GET'
WHERE code = 'system:org:list';

UPDATE permissions SET path = '/api/v1/system/orgs', method = 'POST'
WHERE code = 'system:org:create';

UPDATE permissions SET path = '/api/v1/system/orgs/:id', method = 'PUT'
WHERE code = 'system:org:update';

UPDATE permissions SET path = '/api/v1/system/orgs/:id', method = 'DELETE'
WHERE code = 'system:org:delete';

UPDATE permissions SET path = '/api/v1/system/orgs/tree', method = 'GET'
WHERE code = 'system:org:tree';

UPDATE permissions SET path = '/api/v1/system/files', method = 'GET'
WHERE code = 'system:file:list';

UPDATE permissions SET path = '/api/v1/system/files/upload', method = 'POST'
WHERE code = 'system:file:upload';

UPDATE permissions SET path = '/api/v1/system/files/:id/download', method = 'GET'
WHERE code = 'system:file:download';

UPDATE permissions SET path = '/api/v1/system/files/:id', method = 'DELETE'
WHERE code = 'system:file:delete';

UPDATE permissions SET path = '/api/v1/system/login-logs', method = 'GET'
WHERE code = 'system:loginLog:list';

UPDATE permissions SET path = '/api/v1/system/login-logs/:id', method = 'DELETE'
WHERE code = 'system:loginLog:delete';

UPDATE permissions SET path = '/api/v1/system/login-logs/clear', method = 'POST'
WHERE code = 'system:loginLog:clear';

UPDATE permissions SET path = '/api/v1/system/login-logs/export', method = 'GET'
WHERE code = 'system:loginLog:export';

UPDATE permissions SET path = '/api/v1/system/dict-types', method = 'GET'
WHERE code = 'system:dict:list';

UPDATE permissions SET path = '/api/v1/system/dict-types', method = 'POST'
WHERE code = 'system:dict:create';

UPDATE permissions SET path = '/api/v1/system/dict-types/:id', method = 'PUT'
WHERE code = 'system:dict:update';

UPDATE permissions SET path = '/api/v1/system/dict-types/:id', method = 'DELETE'
WHERE code = 'system:dict:delete';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/check-stock', method = 'POST'
WHERE code = 'sales:checkStock';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/generate-purchase', method = 'POST'
WHERE code = 'sales:generatePurchase';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/outbound', method = 'POST'
WHERE code = 'sales:outbound';

UPDATE permissions SET path = '/api/v1/purchase-orders/:id/inbound', method = 'POST'
WHERE code = 'purchase:inbound';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operationLog:detail',
    'system:role:enable',
    'system:role:disable'
)
WHERE r.code IN ('super_admin', 'admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN (
    'system:operationLog:detail',
    'system:role:enable',
    'system:role:disable'
);


-- ============================================================================
-- Source: 012_frontend_route_alignment.sql
-- ============================================================================
-- Align menu routes with the EleAdminPlus frontend component paths.
-- This migration is intentionally idempotent and can be re-run safely.

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(1, 0, 'dashboard', '/dashboard', 'LAYOUT', '', '工作台', 'Odometer', 1),
(2, 0, 'system', '/system', 'LAYOUT', '/system/users', '系统管理', 'Setting', 2),
(3, 2, 'systemUsers', 'users', '/system/user/index', '', '用户管理', 'User', 1),
(21, 2, 'systemRoles', 'roles', '/system/role/index', '', '角色管理', 'UserFilled', 2),
(22, 2, 'systemMenus', 'menus', '/system/menu/index', '', '菜单管理', 'Menu', 3),
(49, 2, 'systemOrganizations', 'organization', '/system/organization/index', '', '组织架构', 'OfficeBuilding', 4),
(23, 2, 'systemDicts', 'dicts', '/system/dictionary/index', '', '字典管理', 'Collection', 5),
(50, 2, 'systemFiles', 'files', '/system/file/index', '', '文件管理', 'FolderOpened', 6),
(51, 2, 'systemLoginLogs', 'login-record', '/system/login-record/index', '', '登录日志', 'Clock', 7),
(24, 2, 'systemOperationLogs', 'operation-logs', '/system/operation-record/index', '', '操作日志', 'Tickets', 8),
(25, 2, 'systemNumberRules', 'number-rules', '/system/number-rules/index', '', '编号规则', 'Operation', 9),
(4, 0, 'masterData', '/master-data', 'LAYOUT', '/master-data/customers', '基础资料', 'Collection', 3),
(5, 4, 'customers', 'customers', '/customer/index', '', '客户管理', 'UserFilled', 1),
(26, 4, 'suppliers', 'suppliers', '/supplier/index', '', '供应商管理', 'Van', 2),
(6, 4, 'products', 'products', '/product/index', '', '商品管理', 'Goods', 3),
(27, 4, 'skus', 'skus', '/sku/index', '', '商品SKU', 'GoodsFilled', 4),
(28, 4, 'warehouses', 'warehouses', '/warehouse/index', '', '仓库管理', 'House', 5),
(7, 0, 'sales', '/sales', 'LAYOUT', '/sales/quotations', '销售管理', 'Sell', 4),
(8, 7, 'quotations', 'quotations', '/quotation/index', '', '报价单', 'Document', 1),
(9, 7, 'salesOrders', 'orders', '/sales/index', '', '销售订单', 'Tickets', 2),
(29, 7, 'projects', 'projects', '/project/index', '', '项目管理', 'Folder', 3),
(10, 0, 'inventory', '/inventory', 'LAYOUT', '/inventory/stocks', '库存管理', 'Box', 5),
(11, 10, 'stocks', 'stocks', '/inventory/stocks/index', '', '当前库存', 'Box', 1),
(32, 10, 'inboundOrders', 'inbound-orders', '/inventory/inbound-orders/index', '', '入库单', 'Download', 2),
(33, 10, 'outboundOrders', 'outbound-orders', '/inventory/outbound-orders/index', '', '出库单', 'Upload', 3),
(34, 10, 'inventoryRecords', 'records', '/inventory/records/index', '', '库存流水', 'Tickets', 4),
(35, 10, 'serialNumbers', 'serial-numbers', '/serial/index', '', '序列号管理', 'Cpu', 5),
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', '文件管理', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3),
(30, 0, 'purchase', '/purchase', 'LAYOUT', '/purchase/orders', '采购管理', 'ShoppingCart', 7),
(31, 30, 'purchaseOrders', 'orders', '/purchase/index', '', '采购订单', 'Tickets', 1),
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2),
(39, 0, 'finance', '/finance', 'LAYOUT', '/finance/receivables', '财务管理', 'Money', 10),
(40, 39, 'receivables', 'receivables', '/finance/receivables/index', '', '应收记录', 'Coin', 1),
(41, 39, 'payables', 'payables', '/finance/payables/index', '', '应付记录', 'Wallet', 2),
(42, 39, 'receipts', 'receipts', '/finance/receipts/index', '', '收款记录', 'DocumentChecked', 3),
(43, 39, 'payments', 'payments', '/finance/payments/index', '', '付款记录', 'CreditCard', 4),
(44, 0, 'reports', '/reports', 'LAYOUT', '/reports/sales', '报表中心', 'DataAnalysis', 11),
(45, 44, 'salesReport', 'sales', '/reports/sales/index', '', '销售报表', 'TrendCharts', 1),
(46, 44, 'purchaseReport', 'purchase', '/reports/purchase/index', '', '采购报表', 'ShoppingCart', 2),
(47, 44, 'inventoryReport', 'inventory', '/reports/inventory/index', '', '库存报表', 'Box', 3),
(48, 44, 'aftersalesReport', 'aftersales', '/reports/aftersales/index', '', '售后报表', 'Service', 4),
(52, 0, 'messageCenter', '/messages', 'LAYOUT', '/messages/list', '消息中心', 'Message', 12),
(53, 52, 'myMessages', 'list', '/message/list/index', '', '我的消息', 'Message', 1),
(54, 52, 'myTodos', 'todos', '/message/todo/index', '', '我的待办', 'Bell', 2),
(55, 0, 'dataImport', '/import', 'LAYOUT', '/import/tasks', '数据导入', 'UploadFilled', 13),
(56, 55, 'importTasks', 'tasks', '/import/tasks/index', '', '导入任务', 'Upload', 1),
(57, 55, 'importLogs', 'logs', '/import/tasks/index', '', '导入日志', 'Tickets', 2)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
icon = VALUES(icon),
sort = VALUES(sort),
updated_at = CURRENT_TIMESTAMP;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
CROSS JOIN menus m
WHERE r.code IN ('super_admin', 'admin');


-- ============================================================================
-- Source: 013_menu_route_cleanup.sql
-- ============================================================================
-- Cleanup and normalize menu route rows after route alignment.
-- Safe to run repeatedly. Removes duplicate system menu rows created by the
-- early 012 migration draft, then updates menu rows by stable menu name.

DELETE rm
FROM role_menus rm
JOIN menus m ON m.id = rm.menu_id
WHERE m.id IN (12, 13, 14, 15)
  AND m.name IN ('systemRoles', 'systemMenus', 'systemDicts', 'systemOperationLogs');

DELETE FROM menus
WHERE id IN (12, 13, 14, 15)
  AND name IN ('systemRoles', 'systemMenus', 'systemDicts', 'systemOperationLogs');

UPDATE menus
SET path = 'users',
    component = '/system/user/index',
    redirect = '',
    sort = 1,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemUsers';

UPDATE menus
SET path = 'roles',
    component = '/system/role/index',
    redirect = '',
    sort = 2,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemRoles';

UPDATE menus
SET path = 'menus',
    component = '/system/menu/index',
    redirect = '',
    sort = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemMenus';

UPDATE menus
SET path = 'organization',
    component = '/system/organization/index',
    redirect = '',
    sort = 4,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemOrganizations';

UPDATE menus
SET path = 'dicts',
    component = '/system/dictionary/index',
    redirect = '',
    sort = 5,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemDicts';

UPDATE menus
SET path = 'files',
    component = '/system/file/index',
    redirect = '',
    sort = 6,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemFiles';

UPDATE menus
SET path = 'login-record',
    component = '/system/login-record/index',
    redirect = '',
    sort = 7,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemLoginLogs';

UPDATE menus
SET path = 'operation-logs',
    component = '/system/operation-record/index',
    redirect = '',
    sort = 8,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemOperationLogs';

UPDATE menus
SET path = 'number-rules',
    component = '/system/number-rules/index',
    redirect = '',
    sort = 9,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemNumberRules';

UPDATE menus SET path = '/system', component = 'LAYOUT', redirect = '/system/users', updated_at = CURRENT_TIMESTAMP WHERE name = 'system';
UPDATE menus SET path = '/sales', component = 'LAYOUT', redirect = '/sales/quotations', updated_at = CURRENT_TIMESTAMP WHERE name = 'sales';
UPDATE menus SET path = 'quotations', component = '/quotation/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'quotations';
UPDATE menus SET path = 'orders', component = '/sales/index', redirect = '', sort = 2, updated_at = CURRENT_TIMESTAMP WHERE name = 'salesOrders';
UPDATE menus SET path = 'projects', component = '/project/index', redirect = '', sort = 3, updated_at = CURRENT_TIMESTAMP WHERE name = 'projects';
UPDATE menus SET path = '/purchase', component = 'LAYOUT', redirect = '/purchase/orders', updated_at = CURRENT_TIMESTAMP WHERE name = 'purchase';
UPDATE menus SET path = 'orders', component = '/purchase/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'purchaseOrders';
UPDATE menus SET path = '/inventory', component = 'LAYOUT', redirect = '/inventory/stocks', updated_at = CURRENT_TIMESTAMP WHERE name = 'inventory';
UPDATE menus SET path = 'stocks', component = '/inventory/stocks/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'stocks';
UPDATE menus SET path = 'inbound-orders', component = '/inventory/inbound-orders/index', redirect = '', sort = 2, updated_at = CURRENT_TIMESTAMP WHERE name = 'inboundOrders';
UPDATE menus SET path = 'outbound-orders', component = '/inventory/outbound-orders/index', redirect = '', sort = 3, updated_at = CURRENT_TIMESTAMP WHERE name = 'outboundOrders';
UPDATE menus SET path = 'records', component = '/inventory/records/index', redirect = '', sort = 4, updated_at = CURRENT_TIMESTAMP WHERE name = 'inventoryRecords';
UPDATE menus SET path = 'serial-numbers', component = '/serial/index', redirect = '', sort = 5, updated_at = CURRENT_TIMESTAMP WHERE name = 'serialNumbers';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
CROSS JOIN menus m
WHERE r.code IN ('super_admin', 'admin');


-- ============================================================================
-- Source: 014_route_contract_hardening.sql
-- ============================================================================
-- Harden frontend route contract after dynamic route normalization.
-- This migration is safe to run repeatedly. It keeps existing titles intact
-- while aligning path/component/redirect/icon/sort by stable menu name.

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(1, 0, 'dashboard', '/dashboard', 'LAYOUT', '', '工作台', 'Odometer', 1),
(2, 0, 'system', '/system', 'LAYOUT', '/system/users', '系统管理', 'Setting', 2),
(3, 2, 'systemUsers', 'users', '/system/user/index', '', '用户管理', 'User', 1),
(21, 2, 'systemRoles', 'roles', '/system/role/index', '', '角色管理', 'UserFilled', 2),
(22, 2, 'systemMenus', 'menus', '/system/menu/index', '', '菜单管理', 'Menu', 3),
(49, 2, 'systemOrganizations', 'organization', '/system/organization/index', '', '组织架构', 'OfficeBuilding', 4),
(23, 2, 'systemDicts', 'dicts', '/system/dictionary/index', '', '字典管理', 'Collection', 5),
(50, 2, 'systemFiles', 'files', '/system/file/index', '', '文件管理', 'FolderOpened', 6),
(51, 2, 'systemLoginLogs', 'login-record', '/system/login-record/index', '', '登录日志', 'Clock', 7),
(24, 2, 'systemOperationLogs', 'operation-logs', '/system/operation-record/index', '', '操作日志', 'Tickets', 8),
(25, 2, 'systemNumberRules', 'number-rules', '/system/number-rules/index', '', '编号规则', 'Operation', 9),
(4, 0, 'masterData', '/master-data', 'LAYOUT', '/master-data/customers', '基础资料', 'Collection', 3),
(5, 4, 'customers', 'customers', '/customer/index', '', '客户管理', 'UserFilled', 1),
(26, 4, 'suppliers', 'suppliers', '/supplier/index', '', '供应商管理', 'Van', 2),
(6, 4, 'products', 'products', '/product/index', '', '商品管理', 'Goods', 3),
(27, 4, 'skus', 'skus', '/sku/index', '', '商品SKU', 'GoodsFilled', 4),
(28, 4, 'warehouses', 'warehouses', '/warehouse/index', '', '仓库管理', 'House', 5),
(7, 0, 'sales', '/sales', 'LAYOUT', '/sales/quotations', '销售管理', 'Sell', 4),
(8, 7, 'quotations', 'quotations', '/quotation/index', '', '报价单', 'Document', 1),
(9, 7, 'salesOrders', 'orders', '/sales/index', '', '销售订单', 'Tickets', 2),
(29, 7, 'projects', 'projects', '/project/index', '', '项目管理', 'Folder', 3),
(10, 0, 'inventory', '/inventory', 'LAYOUT', '/inventory/stocks', '库存管理', 'Box', 5),
(11, 10, 'stocks', 'stocks', '/inventory/stocks/index', '', '当前库存', 'Box', 1),
(32, 10, 'inboundOrders', 'inbound-orders', '/inventory/inbound-orders/index', '', '入库单', 'Download', 2),
(33, 10, 'outboundOrders', 'outbound-orders', '/inventory/outbound-orders/index', '', '出库单', 'Upload', 3),
(34, 10, 'inventoryRecords', 'records', '/inventory/records/index', '', '库存流水', 'Tickets', 4),
(35, 10, 'serialNumbers', 'serial-numbers', '/serial/index', '', '序列号管理', 'Cpu', 5),
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', '文件管理', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3),
(30, 0, 'purchase', '/purchase', 'LAYOUT', '/purchase/orders', '采购管理', 'ShoppingCart', 7),
(31, 30, 'purchaseOrders', 'orders', '/purchase/index', '', '采购订单', 'Tickets', 1),
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2),
(39, 0, 'finance', '/finance', 'LAYOUT', '/finance/receivables', '财务管理', 'Money', 10),
(40, 39, 'receivables', 'receivables', '/finance/receivables/index', '', '应收记录', 'Coin', 1),
(41, 39, 'payables', 'payables', '/finance/payables/index', '', '应付记录', 'Wallet', 2),
(42, 39, 'receipts', 'receipts', '/finance/receipts/index', '', '收款记录', 'DocumentChecked', 3),
(43, 39, 'payments', 'payments', '/finance/payments/index', '', '付款记录', 'CreditCard', 4),
(44, 0, 'reports', '/reports', 'LAYOUT', '/reports/sales', '报表中心', 'DataAnalysis', 11),
(45, 44, 'salesReport', 'sales', '/reports/sales/index', '', '销售报表', 'TrendCharts', 1),
(46, 44, 'purchaseReport', 'purchase', '/reports/purchase/index', '', '采购报表', 'ShoppingCart', 2),
(47, 44, 'inventoryReport', 'inventory', '/reports/inventory/index', '', '库存报表', 'Box', 3),
(48, 44, 'aftersalesReport', 'aftersales', '/reports/aftersales/index', '', '售后报表', 'Service', 4),
(52, 0, 'messageCenter', '/messages', 'LAYOUT', '/messages/list', '消息中心', 'Message', 12),
(53, 52, 'myMessages', 'list', '/message/list/index', '', '我的消息', 'Message', 1),
(54, 52, 'myTodos', 'todos', '/message/todo/index', '', '我的待办', 'Bell', 2),
(55, 0, 'dataImport', '/import', 'LAYOUT', '/import/tasks', '数据导入', 'UploadFilled', 13),
(56, 55, 'importTasks', 'tasks', '/import/tasks/index', '', '导入任务', 'Upload', 1),
(57, 55, 'importLogs', 'logs', '/import/tasks/index', '', '导入日志', 'Tickets', 2)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
icon = VALUES(icon),
sort = VALUES(sort),
updated_at = CURRENT_TIMESTAMP;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
CROSS JOIN menus m
WHERE r.code IN ('super_admin', 'admin');


-- ============================================================================
-- Source: 015_log_retention.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    module_name VARCHAR(64) NOT NULL,
    action_name VARCHAR(64) NOT NULL,
    business_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    before_data JSON NULL,
    after_data JSON NULL,
    request_id VARCHAR(64) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_audit_logs_module_name (module_name),
    KEY idx_audit_logs_action_name (action_name),
    KEY idx_audit_logs_business (module_name, business_id),
    KEY idx_audit_logs_created_at (created_at)
);

INSERT IGNORE INTO audit_logs (
    id,
    operator_id,
    module_name,
    action_name,
    business_id,
    business_no,
    before_data,
    after_data,
    request_id,
    created_at
)
SELECT
    id,
    operator_id,
    module_name,
    action_name,
    business_id,
    business_no,
    before_data,
    after_data,
    request_id,
    created_at
FROM operation_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE FROM operation_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

DELETE FROM login_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

DELETE FROM audit_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);


-- ============================================================================
-- Source: 016_data_scope_ownership.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('customers', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''客户负责人/销售员ID''', 'status');
CALL add_column_if_missing('customers', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''客户所属机构/团队ID''', 'owner_user_id');
CALL add_column_if_missing('customers', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('customers', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('projects', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''项目所属团队''', 'owner_user_id');
CALL add_column_if_missing('projects', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'remark');
CALL add_column_if_missing('projects', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('quotations', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''报价负责人''', 'converted_sales_order_id');
CALL add_column_if_missing('quotations', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''报价所属团队''', 'owner_user_id');

CALL add_column_if_missing('sales_orders', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售负责人''', 'confirmed_at');
CALL add_column_if_missing('sales_orders', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售所属团队''', 'owner_user_id');

CALL add_column_if_missing('contracts', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同负责人''', 'remark');
CALL add_column_if_missing('contracts', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同所属团队''', 'owner_user_id');

CALL add_column_if_missing('receivables', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''应收所属销售负责人''', 'remark');
CALL add_column_if_missing('receivables', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''应收所属销售团队''', 'owner_user_id');

CALL add_column_if_missing('inventory_outbound_orders', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源销售负责人''', 'updated_by');
CALL add_column_if_missing('inventory_outbound_orders', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源销售团队''', 'owner_user_id');

CALL add_index_if_missing('customers', 'idx_customers_owner_user', '`owner_user_id`');
CALL add_index_if_missing('customers', 'idx_customers_owner_org', '`owner_org_id`');
CALL add_index_if_missing('customers', 'idx_customers_created_by', '`created_by`');
CALL add_index_if_missing('projects', 'idx_projects_owner_user', '`owner_user_id`');
CALL add_index_if_missing('projects', 'idx_projects_owner_org', '`owner_org_id`');
CALL add_index_if_missing('projects', 'idx_projects_created_by', '`created_by`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_user', '`owner_user_id`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_org', '`owner_org_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_user', '`owner_user_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_org', '`owner_org_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_owner_user', '`owner_user_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_owner_org', '`owner_org_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_user', '`owner_user_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_org', '`owner_org_id`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_owner_user', '`owner_user_id`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_owner_org', '`owner_org_id`');

UPDATE customers SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE customers SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE customers c LEFT JOIN users u ON u.id = c.owner_user_id SET c.owner_org_id = u.organization_id WHERE c.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE customers SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE customers SET created_by = owner_user_id WHERE created_by = 0;
UPDATE customers SET updated_by = created_by WHERE updated_by = 0;

UPDATE projects SET created_by = owner_user_id WHERE created_by = 0 AND owner_user_id > 0;
UPDATE projects SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE projects SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE projects p LEFT JOIN users u ON u.id = p.owner_user_id SET p.owner_org_id = u.organization_id WHERE p.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE projects SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE projects SET created_by = owner_user_id WHERE created_by = 0;
UPDATE projects SET updated_by = created_by WHERE updated_by = 0;

UPDATE quotations SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE quotations SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE quotations q LEFT JOIN users u ON u.id = q.owner_user_id SET q.owner_org_id = u.organization_id WHERE q.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE quotations SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE sales_orders SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE sales_orders SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE sales_orders s LEFT JOIN users u ON u.id = s.owner_user_id SET s.owner_org_id = u.organization_id WHERE s.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE sales_orders SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE contracts SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE contracts SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE contracts c LEFT JOIN users u ON u.id = c.owner_user_id SET c.owner_org_id = u.organization_id WHERE c.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE contracts SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE receivables r
JOIN sales_orders s ON s.id = r.sales_order_id
SET r.owner_user_id = s.owner_user_id, r.owner_org_id = s.owner_org_id
WHERE r.owner_user_id = 0 OR r.owner_org_id = 0;
UPDATE receivables SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE receivables r LEFT JOIN users u ON u.id = r.owner_user_id SET r.owner_org_id = u.organization_id WHERE r.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE receivables SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE inventory_outbound_orders o
JOIN sales_orders s ON s.id = o.source_sales_order_id
SET o.owner_user_id = s.owner_user_id, o.owner_org_id = s.owner_org_id
WHERE o.source_sales_order_id > 0 AND (o.owner_user_id = 0 OR o.owner_org_id = 0);

UPDATE roles SET data_scope = 'all' WHERE code IN ('super_admin', 'admin', 'boss');
UPDATE roles SET data_scope = 'team' WHERE code IN ('sales_manager');
UPDATE roles SET data_scope = 'self' WHERE code IN ('sales');

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('customer:transfer', '客户转移', 'api', 'customer', '/api/v1/customers/:id/transfer', 'POST', 209, 'active'),
('customer:assignOwner', '指定客户负责人', 'button', 'customer', '', '', 210, 'active'),
('field:stock_qty:view', '查看库存数量', 'field', 'field', '', '', 2011, 'active'),
('field:available_qty:view', '查看可用库存', 'field', 'field', '', '', 2012, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customer:transfer','customer:assignOwner','field:stock_qty:view','field:available_qty:view')
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('field:stock_qty:view','field:available_qty:view')
WHERE r.code IN ('sales', 'sales_manager', 'purchase', 'purchase_manager', 'warehouse', 'warehouse_manager', 'finance');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager')
  AND p.code IN ('inventory:stock:viewAmount', 'field:stock_amount:view');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 017_permission_boundary_fix.sql
-- ============================================================================
INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('field:customer_contact:view', '查看客户联系方式', 'field', 'field', '', '', 2013, 'active'),
('field:customer_address:view', '查看客户地址', 'field', 'field', '', '', 2014, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list',
    'field:stock_qty:view',
    'field:available_qty:view',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code IN ('sales', 'sales_manager');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('field:customer_contact:view', 'field:customer_address:view')
WHERE r.code IN ('super_admin', 'admin', 'boss');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_manager')
  AND p.code IN (
      'product:create', 'product:update', 'product:delete',
      'sku:create', 'sku:update', 'sku:delete',
      'warehouse:create', 'warehouse:update', 'warehouse:delete',
      'inventory:stock:viewAmount', 'field:stock_amount:view'
  );

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'sales_manager'
  AND p.code IN ('field:gross_profit:view', 'field:gross_margin:view');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager')
  AND p.code = 'sales:list';

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'finance'
  AND p.code = 'customer:list';


-- ============================================================================
-- Source: 018_data_permission_closure.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('aftersales', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''售后关联销售负责人/归属人''', 'sku_id');
CALL add_column_if_missing('aftersales', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''售后关联销售团队/归属团队''', 'owner_user_id');
CALL add_column_if_missing('aftersales', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'closed_at');
CALL add_column_if_missing('aftersales', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_index_if_missing('aftersales', 'idx_aftersales_owner_user', '`owner_user_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_owner_org', '`owner_org_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_order', '`sales_order_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_created_by', '`created_by`');

UPDATE aftersales a
JOIN sales_orders s ON s.id = a.sales_order_id
SET a.owner_user_id = s.owner_user_id,
    a.owner_org_id = s.owner_org_id
WHERE a.sales_order_id > 0
  AND (a.owner_user_id = 0 OR a.owner_org_id = 0);

UPDATE aftersales a
JOIN customers c ON c.id = a.customer_id
SET a.owner_user_id = c.owner_user_id,
    a.owner_org_id = c.owner_org_id
WHERE a.customer_id > 0
  AND (a.owner_user_id = 0 OR a.owner_org_id = 0);

UPDATE aftersales
SET owner_user_id = 1
WHERE owner_user_id = 0
  AND EXISTS (SELECT 1 FROM users WHERE id = 1);

UPDATE aftersales a
LEFT JOIN users u ON u.id = a.owner_user_id
SET a.owner_org_id = u.organization_id
WHERE a.owner_org_id = 0
  AND u.organization_id IS NOT NULL;

UPDATE aftersales SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE aftersales SET created_by = owner_user_id WHERE created_by = 0;
UPDATE aftersales SET updated_by = created_by WHERE updated_by = 0;

UPDATE roles SET data_scope = 'all' WHERE code = 'aftersales';

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'aftersales'
  AND p.code IN ('customer:list', 'sales:list');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 019_data_permission_flow_fix.sql
-- ============================================================================
INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:writeoff:list', 'Finance writeoff list', 'api', 'finance', '/api/v1/finance/writeoffs', 'GET', 1346, 'active'),
('finance:writeoff:reverse', 'Finance writeoff reverse', 'api', 'finance', '/api/v1/finance/writeoffs/reverse', 'POST', 1347, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('finance:writeoff:list', 'finance:writeoff:reverse')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');


-- ============================================================================
-- Source: 020_sales_role_hierarchy.sql
-- ============================================================================
INSERT INTO roles (code, name, data_scope, status, remark) VALUES
('sales_leader', 'Sales Team Leader', 'team', 'active', 'Can view and approve data in the current sales team'),
('sales_director', 'Sales Director', 'org', 'active', 'Can view sales department data and sales gross profit')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
data_scope = VALUES(data_scope),
status = VALUES(status),
remark = VALUES(remark);

UPDATE roles
SET name = 'Sales Manager',
    data_scope = 'org',
    remark = 'Can view and approve data in the sales department and child teams'
WHERE code = 'sales_manager';

UPDATE roles SET data_scope = 'team' WHERE code = 'sales_leader';
UPDATE roles SET data_scope = 'org' WHERE code = 'sales_director';
UPDATE roles SET data_scope = 'all' WHERE code IN ('super_admin', 'admin', 'boss');
UPDATE roles SET data_scope = 'self' WHERE code = 'sales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN (
    'dashboard',
    'customers',
    'projects',
    'quotations',
    'salesOrders',
    'contract',
    'contractList',
    'aftersales',
    'warrantySearch',
    'reports',
    'salesReport'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData', 'sales', 'contract', 'aftersales', 'reports')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('messageCenter', 'myMessages', 'myTodos')
WHERE r.code IN ('sales_leader', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'report:sales:view',
    'field:stock_qty:view',
    'field:available_qty:view'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'message:list',
    'message:todo:list',
    'message:read',
    'message:todo:done',
    'message:delete'
)
WHERE r.code IN ('sales_leader', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list',
    'customer:create',
    'customer:update',
    'project:list',
    'project:create',
    'project:update',
    'project:follow',
    'quotation:list',
    'quotation:create',
    'quotation:update',
    'quotation:submit',
    'quotation:audit',
    'quotation:reject',
    'quotation:confirm',
    'quotation:convert',
    'quotation:copy',
    'quotation:export',
    'quotation:print',
    'sales:list',
    'sales:create',
    'sales:update',
    'sales:submit',
    'sales:audit',
    'sales:reject',
    'sales:confirm',
    'sales:checkStock',
    'sales:generatePurchase',
    'sales:export',
    'sales:print',
    'contract:list',
    'contract:create',
    'contract:upload',
    'contract:download',
    'finance:receivable:list',
    'aftersales:warranty:search',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code = 'sales_leader';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'quotation:audit',
    'quotation:reject',
    'sales:audit',
    'sales:reject',
    'report:sales:view',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code = 'sales_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list',
    'customer:create',
    'customer:update',
    'customer:transfer',
    'customer:assignOwner',
    'project:list',
    'project:create',
    'project:update',
    'project:follow',
    'quotation:list',
    'quotation:create',
    'quotation:update',
    'quotation:submit',
    'quotation:audit',
    'quotation:reject',
    'quotation:confirm',
    'quotation:convert',
    'quotation:copy',
    'quotation:export',
    'quotation:print',
    'quotation:viewProfit',
    'sales:list',
    'sales:create',
    'sales:update',
    'sales:submit',
    'sales:audit',
    'sales:reject',
    'sales:confirm',
    'sales:checkStock',
    'sales:generatePurchase',
    'sales:export',
    'sales:print',
    'sales:viewProfit',
    'contract:list',
    'contract:create',
    'contract:upload',
    'contract:download',
    'finance:receivable:list',
    'report:sales:view',
    'aftersales:warranty:search',
    'field:gross_profit:view',
    'field:gross_margin:view',
    'field:customer_contact:view',
    'field:customer_address:view',
    'field:receivable_amount:view'
)
WHERE r.code = 'sales_director';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customer:transfer', 'customer:assignOwner')
WHERE r.code IN ('sales_manager', 'sales_director');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales_leader', 'sales_manager')
  AND p.code IN (
      'quotation:viewProfit',
      'sales:viewProfit',
      'field:gross_profit:view',
      'field:gross_margin:view',
      'field:cost_price:view',
      'field:purchase_price:view',
      'field:stock_amount:view',
      'inventory:stock:viewAmount'
  );


-- ============================================================================
-- Source: 021_order_profit_snapshots.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('quotation_items', 'cost_price', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('quotation_items', 'gross_profit', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'amount');
CALL add_column_if_missing('quotation_items', 'gross_margin', 'DECIMAL(10,4) NOT NULL DEFAULT 0', 'gross_profit');

CALL add_column_if_missing('sales_order_items', 'cost_price', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('sales_order_items', 'gross_profit', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'amount');
CALL add_column_if_missing('sales_order_items', 'gross_margin', 'DECIMAL(10,4) NOT NULL DEFAULT 0', 'gross_profit');

UPDATE quotation_items qi
JOIN skus s ON s.id = qi.sku_id
SET qi.cost_price = s.cost_price
WHERE qi.cost_price = 0;

UPDATE quotation_items
SET gross_profit = amount - (quantity * cost_price),
    gross_margin = CASE WHEN amount > 0 THEN (amount - (quantity * cost_price)) / amount ELSE 0 END;

UPDATE sales_order_items soi
JOIN skus s ON s.id = soi.sku_id
SET soi.cost_price = s.cost_price
WHERE soi.cost_price = 0;

UPDATE sales_order_items
SET gross_profit = amount - (quantity * cost_price),
    gross_margin = CASE WHEN amount > 0 THEN (amount - (quantity * cost_price)) / amount ELSE 0 END;

DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 022_purchase_price_for_purchase_role.sql
-- ============================================================================
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('purchase:viewPrice', 'field:purchase_price:view')
WHERE r.code = 'purchase';


-- ============================================================================
-- Source: 023_sales_sku_stock_visibility.sql
-- ============================================================================
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list',
    'field:stock_qty:view',
    'field:available_qty:view'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData', 'products', 'skus', 'inventory', 'stocks')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager')
  AND p.code IN (
      'sku:viewCost',
      'inventory:stock:viewAmount',
      'field:cost_price:view',
      'field:purchase_price:view',
      'field:stock_amount:view',
      'field:gross_profit:view',
      'field:gross_margin:view',
      'purchase:viewPrice',
      'quotation:viewProfit',
      'sales:viewCost',
      'sales:viewProfit'
  );


-- ============================================================================
-- Source: 024_order_contact_snapshot_fix.sql
-- ============================================================================
-- Ensure order contact snapshots never keep frontend-masked values.
UPDATE quotations q
JOIN customers c ON c.id = q.customer_id
SET
    q.contact_name = CASE WHEN TRIM(q.contact_name) = '' OR q.contact_name = '***' THEN c.contact_name ELSE q.contact_name END,
    q.contact_phone = CASE WHEN TRIM(q.contact_phone) = '' OR q.contact_phone = '***' THEN c.contact_phone ELSE q.contact_phone END
WHERE TRIM(q.contact_name) = ''
   OR q.contact_name = '***'
   OR TRIM(q.contact_phone) = ''
   OR q.contact_phone = '***';

UPDATE sales_orders so
JOIN customers c ON c.id = so.customer_id
SET
    so.contact_name = CASE WHEN TRIM(so.contact_name) = '' OR so.contact_name = '***' THEN c.contact_name ELSE so.contact_name END,
    so.contact_phone = CASE WHEN TRIM(so.contact_phone) = '' OR so.contact_phone = '***' THEN c.contact_phone ELSE so.contact_phone END
WHERE TRIM(so.contact_name) = ''
   OR so.contact_name = '***'
   OR TRIM(so.contact_phone) = ''
   OR so.contact_phone = '***';


-- ============================================================================
-- Source: 025_query_indexes.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$
CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL add_index_if_missing('sales_orders', 'idx_sales_orders_created_at', '`created_at`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_updated_at', '`updated_at`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_org_status', '`owner_org_id`,`status`');

CALL add_index_if_missing('quotations', 'idx_quotations_created_at', '`created_at`');
CALL add_index_if_missing('quotations', 'idx_quotations_updated_at', '`updated_at`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('quotations', 'idx_quotations_org_status', '`owner_org_id`,`status`');

CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_created_at', '`created_at`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_updated_at', '`updated_at`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_warehouse', '`warehouse_id`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_creator_status', '`created_by`,`status`');

CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_warehouse_sku', '`warehouse_id`,`sku_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_sku_warehouse', '`sku_id`,`warehouse_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_available', '`available_qty`');

CALL add_index_if_missing('inventory_records', 'idx_inventory_records_created_at', '`created_at`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_biz_no', '`biz_no`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_type_created', '`biz_type`,`created_at`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_wh_sku', '`warehouse_id`,`sku_id`');

CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_created_at', '`created_at`');
CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_warehouse_status', '`warehouse_id`,`status`');
CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_supplier_status', '`supplier_id`,`status`');

CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_created_at', '`created_at`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_warehouse_status', '`warehouse_id`,`status`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_customer_status', '`customer_id`,`status`');

CALL add_index_if_missing('receivables', 'idx_receivables_customer_status', '`customer_id`,`status`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('receivables', 'idx_receivables_created_at', '`created_at`');
CALL add_index_if_missing('receivables', 'idx_receivables_due_date', '`due_date`');

CALL add_index_if_missing('payables', 'idx_payables_supplier_status', '`supplier_id`,`status`');
CALL add_index_if_missing('payables', 'idx_payables_created_at', '`created_at`');
CALL add_index_if_missing('payables', 'idx_payables_due_date', '`due_date`');

CALL add_index_if_missing('aftersales', 'idx_aftersales_created_at', '`created_at`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sku_status', '`sku_id`,`status`');

DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 026_simplified_chinese_display_names.sql
-- ============================================================================
-- Normalize visible names and existing message content to Simplified Chinese.
-- Safe to run repeatedly.

UPDATE users
SET display_name = '系统管理员'
WHERE username = 'admin' AND display_name IN ('System Admin', 'Admin', 'Administrator');

UPDATE roles
SET name = '超级管理员'
WHERE code = 'super_admin' AND name IN ('Super Admin', 'Administrator');

UPDATE permissions
SET name = CASE code
    WHEN 'message:list' THEN '查看消息'
    WHEN 'message:todo:list' THEN '查看待办消息'
    WHEN 'message:read' THEN '标记消息已读'
    WHEN 'message:todo:done' THEN '完成待办消息'
    WHEN 'message:delete' THEN '删除消息'
    ELSE name
END
WHERE code IN ('message:list','message:todo:list','message:read','message:todo:done','message:delete');

UPDATE menus
SET title = CASE name
    WHEN 'dashboard' THEN '工作台'
    WHEN 'system' THEN '系统管理'
    WHEN 'systemUsers' THEN '用户管理'
    WHEN 'systemRoles' THEN '角色管理'
    WHEN 'systemMenus' THEN '菜单管理'
    WHEN 'systemOrganizations' THEN '组织架构'
    WHEN 'systemDicts' THEN '字典管理'
    WHEN 'systemFiles' THEN '文件管理'
    WHEN 'systemLoginLogs' THEN '登录日志'
    WHEN 'systemOperationLogs' THEN '操作日志'
    WHEN 'systemNumberRules' THEN '编号规则'
    WHEN 'masterData' THEN '基础资料'
    WHEN 'customers' THEN '客户管理'
    WHEN 'suppliers' THEN '供应商管理'
    WHEN 'products' THEN '商品管理'
    WHEN 'skus' THEN '商品SKU'
    WHEN 'warehouses' THEN '仓库管理'
    WHEN 'sales' THEN '销售管理'
    WHEN 'quotations' THEN '报价单'
    WHEN 'salesOrders' THEN '销售订单'
    WHEN 'projects' THEN '项目管理'
    WHEN 'inventory' THEN '库存管理'
    WHEN 'stocks' THEN '当前库存'
    WHEN 'inboundOrders' THEN '入库单'
    WHEN 'outboundOrders' THEN '出库单'
    WHEN 'inventoryRecords' THEN '库存流水'
    WHEN 'serialNumbers' THEN '序列号管理'
    WHEN 'contract' THEN '合同管理'
    WHEN 'contractTemplates' THEN '合同模板'
    WHEN 'contractList' THEN '合同列表'
    WHEN 'contractFiles' THEN '合同附件'
    WHEN 'purchase' THEN '采购管理'
    WHEN 'purchaseOrders' THEN '采购订单'
    WHEN 'aftersales' THEN '售后管理'
    WHEN 'aftersalesTickets' THEN '售后工单'
    WHEN 'warrantySearch' THEN '质保查询'
    WHEN 'finance' THEN '财务管理'
    WHEN 'receivables' THEN '应收记录'
    WHEN 'payables' THEN '应付记录'
    WHEN 'receipts' THEN '收款记录'
    WHEN 'payments' THEN '付款记录'
    WHEN 'reports' THEN '报表中心'
    WHEN 'salesReport' THEN '销售报表'
    WHEN 'purchaseReport' THEN '采购报表'
    WHEN 'inventoryReport' THEN '库存报表'
    WHEN 'aftersalesReport' THEN '售后报表'
    WHEN 'messageCenter' THEN '消息中心'
    WHEN 'myMessages' THEN '我的消息'
    WHEN 'myTodos' THEN '我的待办'
    WHEN 'dataImport' THEN '数据导入'
    WHEN 'importTasks' THEN '导入任务'
    WHEN 'importLogs' THEN '导入日志'
    ELSE title
END
WHERE name IN (
    'dashboard','system','systemUsers','systemRoles','systemMenus','systemOrganizations',
    'systemDicts','systemFiles','systemLoginLogs','systemOperationLogs','systemNumberRules',
    'masterData','customers','suppliers','products','skus','warehouses','sales','quotations',
    'salesOrders','projects','inventory','stocks','inboundOrders','outboundOrders',
    'inventoryRecords','serialNumbers','contract','contractTemplates','contractList',
    'contractFiles','purchase','purchaseOrders','aftersales','aftersalesTickets',
    'warrantySearch','finance','receivables','payables','receipts','payments','reports',
    'salesReport','purchaseReport','inventoryReport','aftersalesReport','messageCenter',
    'myMessages','myTodos','dataImport','importTasks','importLogs'
);

UPDATE messages
SET title = '采购订单待入库'
WHERE title = 'purchase order pending inbound';

UPDATE messages
SET title = '采购入库待处理'
WHERE title = 'purchase inbound pending';

UPDATE messages
SET content = CONCAT('采购订单 ', biz_no, ' 已确认，请处理入库和应付')
WHERE content LIKE 'purchase order % confirmed, please handle inbound and payable';

UPDATE messages
SET content = REPLACE(REPLACE(content, 'purchase order ', '采购订单 '), ' generated inbound order ', ' 已生成入库单 ')
WHERE content LIKE 'purchase order % generated inbound order %';


-- ============================================================================
-- Source: 027_customer_code_auto_generate.sql
-- ============================================================================
INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('customer', '客户编号', 'KH', '20060102', 4, 'active', '客户新增时自动生成编号')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);


-- ============================================================================
-- Source: 028_operation_log_request_fields.sql
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS add_column_if_missing//
DROP PROCEDURE IF EXISTS add_index_if_missing//

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            CASE WHEN p_after_column IS NULL OR p_after_column = '' THEN '' ELSE CONCAT(' AFTER `', p_after_column, '`') END
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

CALL add_column_if_missing('operation_logs', 'request_path', 'VARCHAR(255) NOT NULL DEFAULT ''''', 'business_no');
CALL add_column_if_missing('operation_logs', 'request_method', 'VARCHAR(20) NOT NULL DEFAULT ''''', 'request_path');
CALL add_column_if_missing('operation_logs', 'request_params', 'TEXT NULL', 'request_method');
CALL add_column_if_missing('operation_logs', 'result', 'VARCHAR(32) NOT NULL DEFAULT ''success''', 'request_params');
CALL add_column_if_missing('operation_logs', 'ip_address', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'result');
CALL add_index_if_missing('operation_logs', 'idx_operation_logs_request_path', '`request_path`(191)');
CALL add_index_if_missing('operation_logs', 'idx_operation_logs_ip_address', '`ip_address`');

CALL add_column_if_missing('audit_logs', 'request_path', 'VARCHAR(255) NOT NULL DEFAULT ''''', 'business_no');
CALL add_column_if_missing('audit_logs', 'request_method', 'VARCHAR(20) NOT NULL DEFAULT ''''', 'request_path');
CALL add_column_if_missing('audit_logs', 'request_params', 'TEXT NULL', 'request_method');
CALL add_column_if_missing('audit_logs', 'result', 'VARCHAR(32) NOT NULL DEFAULT ''success''', 'request_params');
CALL add_column_if_missing('audit_logs', 'ip_address', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'result');
CALL add_index_if_missing('audit_logs', 'idx_audit_logs_request_path', '`request_path`(191)');
CALL add_index_if_missing('audit_logs', 'idx_audit_logs_ip_address', '`ip_address`');

DROP PROCEDURE add_index_if_missing;
DROP PROCEDURE add_column_if_missing;


-- ============================================================================
-- Source: 029_finance_phase1_payment_workflow.sql
-- ============================================================================
DELIMITER //

DROP PROCEDURE IF EXISTS add_column_if_missing//
DROP PROCEDURE IF EXISTS add_index_if_missing//

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            CASE WHEN p_after_column IS NULL OR p_after_column = '' THEN '' ELSE CONCAT(' AFTER `', p_after_column, '`') END
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

CALL add_column_if_missing('receivables', 'source_type', 'VARCHAR(50) NOT NULL DEFAULT ''sales_order'' COMMENT ''来源类型''', 'receivable_no');
CALL add_column_if_missing('receivables', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('receivables', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号''', 'sales_order_id');
CALL add_column_if_missing('receivables', 'customer_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''客户名称''', 'customer_id');
CALL add_column_if_missing('receivables', 'unreceived_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''未收金额''', 'received_amount');
CALL add_column_if_missing('receivables', 'receivable_date', 'DATE NULL COMMENT ''应收日期''', 'status');
CALL add_column_if_missing('receivables', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('receivables', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('payables', 'source_type', 'VARCHAR(50) NOT NULL DEFAULT ''purchase_order'' COMMENT ''来源类型''', 'payable_no');
CALL add_column_if_missing('payables', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('payables', 'purchase_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''采购订单号''', 'purchase_order_id');
CALL add_column_if_missing('payables', 'supplier_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''供应商名称''', 'supplier_id');
CALL add_column_if_missing('payables', 'unpaid_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''未付金额''', 'paid_amount');
CALL add_column_if_missing('payables', 'payable_date', 'DATE NULL COMMENT ''应付日期''', 'status');
CALL add_column_if_missing('payables', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购负责人''', 'remark');
CALL add_column_if_missing('payables', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购团队''', 'owner_user_id');
CALL add_column_if_missing('payables', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('payables', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('receipts', 'receivable_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''应收编号''', 'receivable_id');
CALL add_column_if_missing('receipts', 'sales_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售订单ID''', 'receivable_no');
CALL add_column_if_missing('receipts', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号''', 'sales_order_id');
CALL add_column_if_missing('receipts', 'customer_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''客户名称''', 'customer_id');
CALL add_column_if_missing('receipts', 'receipt_method', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''收款方式''', 'amount');
CALL add_column_if_missing('receipts', 'receipt_date', 'DATE NULL COMMENT ''收款日期''', 'receipt_method');
CALL add_column_if_missing('receipts', 'transaction_no', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''交易流水号''', 'receipt_date');
CALL add_column_if_missing('receipts', 'attachment_file_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''凭证附件ID''', 'transaction_no');
CALL add_column_if_missing('receipts', 'cancelled_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''作废人''', 'created_by');
CALL add_column_if_missing('receipts', 'cancelled_at', 'DATETIME NULL COMMENT ''作废时间''', 'cancelled_by');

CALL add_column_if_missing('payments', 'payable_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''应付编号''', 'payable_id');
CALL add_column_if_missing('payments', 'purchase_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购订单ID''', 'payable_no');
CALL add_column_if_missing('payments', 'purchase_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''采购订单号''', 'purchase_order_id');
CALL add_column_if_missing('payments', 'supplier_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''供应商名称''', 'supplier_id');
CALL add_column_if_missing('payments', 'payment_method', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''付款方式''', 'amount');
CALL add_column_if_missing('payments', 'payment_date', 'DATE NULL COMMENT ''付款日期''', 'payment_method');
CALL add_column_if_missing('payments', 'transaction_no', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''交易流水号''', 'payment_date');
CALL add_column_if_missing('payments', 'attachment_file_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''凭证附件ID''', 'transaction_no');
CALL add_column_if_missing('payments', 'cancelled_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''作废人''', 'created_by');
CALL add_column_if_missing('payments', 'cancelled_at', 'DATETIME NULL COMMENT ''作废时间''', 'cancelled_by');

UPDATE receivables r
LEFT JOIN sales_orders so ON so.id = r.sales_order_id
LEFT JOIN customers c ON c.id = r.customer_id
SET r.source_type = 'sales_order',
    r.source_id = CASE WHEN r.source_id = 0 THEN r.sales_order_id ELSE r.source_id END,
    r.sales_order_no = COALESCE(NULLIF(r.sales_order_no, ''), so.sales_order_no, ''),
    r.customer_name = COALESCE(NULLIF(r.customer_name, ''), c.name, ''),
    r.unreceived_amount = GREATEST(r.amount - r.received_amount, 0),
    r.receivable_date = COALESCE(r.receivable_date, DATE(r.created_at)),
    r.status = CASE r.status
        WHEN 'pending' THEN 'unpaid'
        WHEN 'partial' THEN 'partial_paid'
        WHEN 'voided' THEN 'cancelled'
        ELSE r.status
    END;

UPDATE payables p
LEFT JOIN purchase_orders po ON po.id = p.purchase_order_id
LEFT JOIN suppliers s ON s.id = p.supplier_id
LEFT JOIN users u ON u.id = po.created_by
SET p.source_type = 'purchase_order',
    p.source_id = CASE WHEN p.source_id = 0 THEN p.purchase_order_id ELSE p.source_id END,
    p.purchase_order_no = COALESCE(NULLIF(p.purchase_order_no, ''), po.purchase_order_no, ''),
    p.supplier_name = COALESCE(NULLIF(p.supplier_name, ''), s.name, ''),
    p.unpaid_amount = GREATEST(p.amount - p.paid_amount, 0),
    p.payable_date = COALESCE(p.payable_date, DATE(p.created_at)),
    p.owner_user_id = CASE WHEN p.owner_user_id = 0 THEN COALESCE(po.created_by, 0) ELSE p.owner_user_id END,
    p.owner_org_id = CASE WHEN p.owner_org_id = 0 THEN COALESCE(u.organization_id, 0) ELSE p.owner_org_id END,
    p.status = CASE p.status
        WHEN 'pending' THEN 'unpaid'
        WHEN 'partial' THEN 'partial_paid'
        WHEN 'voided' THEN 'cancelled'
        ELSE p.status
    END;

UPDATE receipts rc
LEFT JOIN receivables r ON r.id = rc.receivable_id
SET rc.receivable_no = COALESCE(NULLIF(rc.receivable_no, ''), r.receivable_no, ''),
    rc.sales_order_id = CASE WHEN rc.sales_order_id = 0 THEN COALESCE(r.sales_order_id, 0) ELSE rc.sales_order_id END,
    rc.sales_order_no = COALESCE(NULLIF(rc.sales_order_no, ''), r.sales_order_no, ''),
    rc.customer_name = COALESCE(NULLIF(rc.customer_name, ''), r.customer_name, ''),
    rc.receipt_date = COALESCE(rc.receipt_date, DATE(rc.received_at), DATE(rc.created_at)),
    rc.status = CASE rc.status WHEN 'active' THEN 'confirmed' ELSE rc.status END;

UPDATE payments pm
LEFT JOIN payables p ON p.id = pm.payable_id
SET pm.payable_no = COALESCE(NULLIF(pm.payable_no, ''), p.payable_no, ''),
    pm.purchase_order_id = CASE WHEN pm.purchase_order_id = 0 THEN COALESCE(p.purchase_order_id, 0) ELSE pm.purchase_order_id END,
    pm.purchase_order_no = COALESCE(NULLIF(pm.purchase_order_no, ''), p.purchase_order_no, ''),
    pm.supplier_name = COALESCE(NULLIF(pm.supplier_name, ''), p.supplier_name, ''),
    pm.payment_date = COALESCE(pm.payment_date, DATE(pm.paid_at), DATE(pm.created_at)),
    pm.status = CASE pm.status WHEN 'active' THEN 'confirmed' ELSE pm.status END;

CALL add_index_if_missing('receivables', 'idx_receivables_source', '`source_type`, `source_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_sales_order_no', '`sales_order_no`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_user_id', '`owner_user_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_org_id', '`owner_org_id`');
CALL add_index_if_missing('payables', 'idx_payables_source', '`source_type`, `source_id`');
CALL add_index_if_missing('payables', 'idx_payables_purchase_order_no', '`purchase_order_no`');
CALL add_index_if_missing('payables', 'idx_payables_owner_user_id', '`owner_user_id`');
CALL add_index_if_missing('payables', 'idx_payables_owner_org_id', '`owner_org_id`');
CALL add_index_if_missing('receipts', 'idx_receipts_sales_order_id', '`sales_order_id`');
CALL add_index_if_missing('receipts', 'idx_receipts_status', '`status`');
CALL add_index_if_missing('payments', 'idx_payments_purchase_order_id', '`purchase_order_id`');
CALL add_index_if_missing('payments', 'idx_payments_status', '`status`');

DROP PROCEDURE add_index_if_missing;
DROP PROCEDURE add_column_if_missing;


-- ============================================================================
-- Source: 030_export_permission_super_admin_only.sql
-- ============================================================================
-- Export is restricted to the super admin account/role only.
-- Remove all export-style permissions from non-super-admin roles.

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code <> 'super_admin'
  AND LOWER(p.code) LIKE '%export%';


-- ============================================================================
-- Source: 031_customer_visibility_sales_only.sql
-- ============================================================================
-- Customer visibility is limited to the sales ownership chain.
-- Super admin can see all customers. Sales users see their own customers.
-- Sales leaders/managers/directors see their team or department scope.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('field:customer_contact:view', '查看客户联系方式', 'field', 'field', '', '', 2013, 'active'),
('field:customer_address:view', '查看客户地址', 'field', 'field', '', '', 2014, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code IN ('super_admin', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code NOT IN ('super_admin', 'sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
      'customer:list',
      'customer:create',
      'customer:update',
      'customer:delete',
      'customer:transfer',
      'customer:assignOwner',
      'field:customer_contact:view',
      'field:customer_address:view'
  );


-- ============================================================================
-- Source: 032_product_brand_category_foundation.sql
-- ============================================================================
-- Product category + brand category foundation for first-phase SKU selection and inventory filtering.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    category_code VARCHAR(64) NOT NULL,
    category_name VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_product_categories_code (category_code),
    KEY idx_product_categories_parent (parent_id),
    KEY idx_product_categories_status (status),
    KEY idx_product_categories_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

CREATE TABLE IF NOT EXISTS brand_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    category_code VARCHAR(64) NOT NULL,
    category_name VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_categories_code (category_code),
    KEY idx_brand_categories_parent (parent_id),
    KEY idx_brand_categories_status (status),
    KEY idx_brand_categories_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌分类';

CREATE TABLE IF NOT EXISTS brands (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_code VARCHAR(64) NOT NULL,
    brand_name VARCHAR(128) NOT NULL,
    logo_file_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brands_code (brand_code),
    KEY idx_brands_category (brand_category_id),
    KEY idx_brands_status (status),
    KEY idx_brands_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌';

CALL add_column_if_missing('products', 'product_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'category');
CALL add_column_if_missing('products', 'brand_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_category_id');
CALL add_column_if_missing('products', 'brand_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'brand_category_id');
CALL add_column_if_missing('skus', 'product_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_id');
CALL add_column_if_missing('skus', 'brand_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_category_id');
CALL add_column_if_missing('skus', 'brand_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'brand_category_id');

CALL add_index_if_missing('products', 'idx_products_product_category', '`product_category_id`');
CALL add_index_if_missing('products', 'idx_products_brand_category', '`brand_category_id`');
CALL add_index_if_missing('products', 'idx_products_brand_id', '`brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_product_category', '`product_category_id`');
CALL add_index_if_missing('skus', 'idx_skus_brand_category', '`brand_category_id`');
CALL add_index_if_missing('skus', 'idx_skus_brand_id', '`brand_id`');

INSERT INTO product_categories (category_code, category_name, sort, status, remark)
SELECT CONCAT('PC_', UPPER(LEFT(MD5(TRIM(category)), 12))), TRIM(category), 100, 'active', 'Migrated from products.category'
FROM (
    SELECT DISTINCT category
    FROM products
    WHERE deleted_at IS NULL AND TRIM(category) <> ''
) src
ON DUPLICATE KEY UPDATE
category_name = VALUES(category_name),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO brand_categories (category_code, category_name, sort, status, remark)
VALUES ('BC_DEFAULT', '默认品牌分类', 100, 'active', 'Default brand category for migrated brands')
ON DUPLICATE KEY UPDATE
category_name = VALUES(category_name),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO brands (brand_category_id, brand_code, brand_name, sort, status, remark)
SELECT bc.id, CONCAT('BR_', UPPER(LEFT(MD5(TRIM(src.brand)), 12))), TRIM(src.brand), 100, 'active', 'Migrated from products.brand'
FROM (
    SELECT DISTINCT brand
    FROM products
    WHERE deleted_at IS NULL AND TRIM(brand) <> ''
) src
JOIN brand_categories bc ON bc.category_code = 'BC_DEFAULT'
ON DUPLICATE KEY UPDATE
brand_name = VALUES(brand_name),
brand_category_id = VALUES(brand_category_id),
updated_at = CURRENT_TIMESTAMP;

UPDATE products p
LEFT JOIN product_categories pc ON BINARY pc.category_name = BINARY p.category
LEFT JOIN brands b ON BINARY b.brand_name = BINARY p.brand
SET p.product_category_id = COALESCE(pc.id, 0),
    p.brand_id = COALESCE(b.id, 0),
    p.brand_category_id = COALESCE(b.brand_category_id, 0),
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL;

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(58, 4, 'productCategories', 'product-categories', '/product/category/index', '', '商品分类', 'CollectionTag', 3),
(59, 4, 'brandCategories', 'brand-categories', '/brand/category/index', '', '品牌分类', 'PriceTag', 4),
(60, 4, 'brands', 'brands', '/brand/index', '', '品牌管理', 'Discount', 5)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort),
updated_at = CURRENT_TIMESTAMP;

UPDATE menus SET sort = 6, updated_at = CURRENT_TIMESTAMP WHERE name = 'products';
UPDATE menus SET sort = 7, updated_at = CURRENT_TIMESTAMP WHERE name = 'skus';
UPDATE menus SET sort = 8, updated_at = CURRENT_TIMESTAMP WHERE name = 'warehouses';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('productCategory:list', '商品分类列表', 'api', 'product', '/api/v1/product-categories', 'GET', 431, 'active'),
('productCategory:create', '新增商品分类', 'api', 'product', '/api/v1/product-categories', 'POST', 432, 'active'),
('productCategory:update', '编辑商品分类', 'api', 'product', '/api/v1/product-categories/:id', 'PUT', 433, 'active'),
('productCategory:delete', '删除商品分类', 'api', 'product', '/api/v1/product-categories/:id', 'DELETE', 434, 'active'),
('productCategory:enable', '启用商品分类', 'button', 'product', '', '', 435, 'active'),
('productCategory:disable', '停用商品分类', 'button', 'product', '', '', 436, 'active'),
('brandCategory:list', '品牌分类列表', 'api', 'product', '/api/v1/brand-categories', 'GET', 441, 'active'),
('brandCategory:create', '新增品牌分类', 'api', 'product', '/api/v1/brand-categories', 'POST', 442, 'active'),
('brandCategory:update', '编辑品牌分类', 'api', 'product', '/api/v1/brand-categories/:id', 'PUT', 443, 'active'),
('brandCategory:delete', '删除品牌分类', 'api', 'product', '/api/v1/brand-categories/:id', 'DELETE', 444, 'active'),
('brandCategory:enable', '启用品牌分类', 'button', 'product', '', '', 445, 'active'),
('brandCategory:disable', '停用品牌分类', 'button', 'product', '', '', 446, 'active'),
('brand:list', '品牌列表', 'api', 'product', '/api/v1/brands', 'GET', 451, 'active'),
('brand:create', '新增品牌', 'api', 'product', '/api/v1/brands', 'POST', 452, 'active'),
('brand:update', '编辑品牌', 'api', 'product', '/api/v1/brands/:id', 'PUT', 453, 'active'),
('brand:delete', '删除品牌', 'api', 'product', '/api/v1/brands/:id', 'DELETE', 454, 'active'),
('brand:enable', '启用品牌', 'button', 'product', '', '', 455, 'active'),
('brand:disable', '停用品牌', 'button', 'product', '', '', 456, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (58, 59, 60)
WHERE r.code IN ('super_admin', 'boss', 'product_admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'productCategory:list','productCategory:create','productCategory:update','productCategory:delete','productCategory:enable','productCategory:disable',
    'brandCategory:list','brandCategory:create','brandCategory:update','brandCategory:delete','brandCategory:enable','brandCategory:disable',
    'brand:list','brand:create','brand:update','brand:delete','brand:enable','brand:disable'
)
WHERE r.code IN ('super_admin', 'boss', 'product_admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('productCategory:list', 'brandCategory:list', 'brand:list')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director', 'purchase', 'purchase_manager', 'warehouse', 'warehouse_manager');

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 033_master_data_linkage_upgrade.sql
-- ============================================================================
-- Upgrade master data linkage for product category, brand category, brand, product, SKU, and stock views.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('product_categories', 'default_unit', 'VARCHAR(32) NOT NULL DEFAULT ''''', 'category_name');
CALL add_column_if_missing('product_categories', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'default_unit');
CALL add_column_if_missing('product_categories', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_stock_item');
CALL add_column_if_missing('product_categories', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');

CALL add_column_if_missing('brands', 'brand_short_name', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'brand_name');
CALL add_column_if_missing('brands', 'brand_en_name', 'VARCHAR(128) NOT NULL DEFAULT ''''', 'brand_short_name');
CALL add_column_if_missing('brands', 'default_supplier_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'logo_file_id');
CALL add_column_if_missing('brands', 'is_common', 'TINYINT(1) NOT NULL DEFAULT 0', 'default_supplier_id');
CALL add_column_if_missing('brands', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_common');
CALL add_column_if_missing('brands', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');
CALL add_column_if_missing('brands', 'show_in_quotation', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_purchase');
CALL add_column_if_missing('brands', 'show_in_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'show_in_quotation');

CALL add_column_if_missing('products', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'unit');
CALL add_column_if_missing('products', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_stock_item');
CALL add_column_if_missing('products', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');

CALL add_column_if_missing('skus', 'model', 'VARCHAR(128) NOT NULL DEFAULT ''''', 'spec');
CALL add_column_if_missing('skus', 'stock_warning_qty', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'purchase_price');
CALL add_column_if_missing('skus', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'stock_warning_qty');
CALL add_column_if_missing('skus', 'remark', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'is_stock_item');

CALL add_index_if_missing('brands', 'idx_brands_default_supplier', '`default_supplier_id`');

CREATE TABLE IF NOT EXISTS brand_category_product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_category_id BIGINT UNSIGNED NOT NULL,
    product_category_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_category_product_category (brand_category_id, product_category_id),
    KEY idx_bcpc_brand_category (brand_category_id),
    KEY idx_bcpc_product_category (product_category_id),
    KEY idx_bcpc_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌分类适用商品分类';

CREATE TABLE IF NOT EXISTS brand_product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_id BIGINT UNSIGNED NOT NULL,
    product_category_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_product_category (brand_id, product_category_id),
    KEY idx_bpc_brand (brand_id),
    KEY idx_bpc_product_category (product_category_id),
    KEY idx_bpc_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌适用商品分类';

INSERT IGNORE INTO brand_category_product_categories (brand_category_id, product_category_id)
SELECT DISTINCT p.brand_category_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_category_id > 0
  AND p.product_category_id > 0;

INSERT IGNORE INTO brand_product_categories (brand_id, product_category_id)
SELECT DISTINCT p.brand_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0
  AND p.product_category_id > 0;

UPDATE products p
JOIN brands b ON b.id = p.brand_id
SET p.brand_category_id = b.brand_category_id,
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0;

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.model = IF(s.model = '', p.model, s.model),
    s.is_stock_item = p.is_stock_item,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL;

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 034_dashboard_report_phase1_upgrade.sql
-- ============================================================================
INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (64, 44, 'financeReport', 'finance', '/reports/finance/index', '', '财务报表', 'Money', 4)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

UPDATE menus SET sort = 5 WHERE name = 'aftersalesReport';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('report:finance:view', '财务报表查看', 'api', 'report', '/api/v1/reports/finance', 'GET', 1531, 'active'),
('report:finance:export', '财务报表导出', 'button', 'report', '', '', 1532, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'financeReport'
WHERE r.code IN ('super_admin', 'boss', 'finance', 'auditor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'report:finance:view'
WHERE r.code IN ('super_admin', 'boss', 'finance', 'auditor');


-- ============================================================================
-- Source: 035_system_profile_menu.sql
-- ============================================================================
INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (61, 2, 'systemProfile', 'profile', '/user/profile/index', '', '个人设置', 'User', 10)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'system'
WHERE r.status = 'active';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'systemProfile'
WHERE r.status = 'active';


-- ============================================================================
-- Source: 036_system_app_setting.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS system_app_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  project_name VARCHAR(128) NOT NULL DEFAULT '',
  logo_url MEDIUMTEXT NULL,
  updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统外观设置';

INSERT INTO system_app_settings (id, project_name, logo_url, updated_by)
VALUES (1, '圣泰安科技', '', 0)
ON DUPLICATE KEY UPDATE
project_name = IF(project_name = '', VALUES(project_name), project_name);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (63, 2, 'systemAppSetting', 'app-setting', '/system/app-setting/index', '', '系统外观', 'Brush', 10)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

UPDATE menus SET sort = 11 WHERE name = 'systemProfile';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:app-setting:view', '系统外观查看', 'api', 'system', '/api/v1/system/app-setting', 'GET', 1960, 'active'),
('system:app-setting:update', '系统外观保存', 'api', 'system', '/api/v1/system/app-setting', 'PUT', 1961, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'systemAppSetting'
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('system:app-setting:view', 'system:app-setting:update')
WHERE r.code IN ('super_admin', 'admin', 'boss');


-- ============================================================================
-- Source: 037_product_sku_code_permissions.sql
-- ============================================================================
INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('product:updateCode', '修改商品编码', 'button', 'product', '', '', 409, 'active'),
('sku:updateCode', '修改SKU编码', 'button', 'sku', '', '', 431, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('product:updateCode', 'sku:updateCode')
WHERE r.code IN ('super_admin', 'product_admin');


-- ============================================================================
-- Source: 038_inventory_check_phase1.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_check_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    check_no VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL DEFAULT '',
    check_type VARCHAR(30) NOT NULL,
    product_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_ids VARCHAR(1000) NOT NULL DEFAULT '',
    system_total_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    actual_total_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    profit_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    loss_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    diff_sku_count INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'draft',
    check_date DATE NULL,
    check_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    submit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    submit_time DATETIME NULL,
    audit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    audit_time DATETIME NULL,
    adjust_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    adjust_time DATETIME NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    INDEX idx_inventory_check_no (check_no),
    INDEX idx_inventory_check_warehouse_id (warehouse_id),
    INDEX idx_inventory_check_status (status),
    INDEX idx_inventory_check_date (check_date)
) COMMENT='inventory check orders';

CREATE TABLE IF NOT EXISTS inventory_check_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    check_order_id BIGINT UNSIGNED NOT NULL,
    check_no VARCHAR(50) NOT NULL,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_code VARCHAR(100) NOT NULL,
    sku_name VARCHAR(200) NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    product_name VARCHAR(200) NOT NULL DEFAULT '',
    product_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    product_category_name VARCHAR(100) NOT NULL DEFAULT '',
    brand_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_category_name VARCHAR(100) NOT NULL DEFAULT '',
    brand_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_name VARCHAR(100) NOT NULL DEFAULT '',
    model VARCHAR(128) NOT NULL DEFAULT '',
    spec VARCHAR(255) NOT NULL DEFAULT '',
    warehouse_id BIGINT UNSIGNED NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL DEFAULT '',
    system_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    actual_qty DECIMAL(18,4) NULL,
    diff_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    diff_type VARCHAR(30) NOT NULL DEFAULT 'none',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inventory_check_item_order_id (check_order_id),
    INDEX idx_inventory_check_item_sku_id (sku_id),
    INDEX idx_inventory_check_item_warehouse_id (warehouse_id),
    INDEX idx_inventory_check_item_diff_type (diff_type)
) COMMENT='inventory check items';

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('inventory_check', '库存盘点单号', 'PD', '20060102', 4, 'active', '库存盘点单自动编号')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('inventory:check:list', '库存盘点列表', 'api', 'inventory', '/api/v1/inventory/check-orders', 'GET', 1040, 'active'),
('inventory:check:create', '创建库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders', 'POST', 1041, 'active'),
('inventory:check:update', '录入库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id', 'PUT', 1042, 'active'),
('inventory:check:delete', '删除库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id', 'DELETE', 1043, 'active'),
('inventory:check:start', '开始库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/start', 'POST', 1044, 'active'),
('inventory:check:submit', '提交库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/submit', 'POST', 1045, 'active'),
('inventory:check:audit', '审核库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/audit', 'POST', 1046, 'active'),
('inventory:check:reject', '驳回库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/reject', 'POST', 1047, 'active'),
('inventory:check:adjust', '确认盘点调整', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/adjust', 'POST', 1048, 'active'),
('inventory:check:cancel', '取消库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/cancel', 'POST', 1049, 'active'),
('inventory:check:export', '导出库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/export', 'GET', 1050, 'active'),
('inventory:check:print', '打印库存盘点', 'api', 'inventory', '/api/v1/inventory/check-orders/:id/print', 'GET', 1051, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:check:list','inventory:check:create','inventory:check:update','inventory:check:start',
    'inventory:check:submit','inventory:check:export','inventory:check:print'
)
WHERE r.code IN ('super_admin', 'warehouse', 'warehouse_staff', 'warehouse_admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code LIKE 'inventory:check:%'
WHERE r.code IN ('super_admin', 'warehouse_manager', 'warehouse_admin');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 62, id, 'inventoryChecks', 'check-orders', '/inventory/check-orders/index', '', '库存盘点', 'Tickets', 5
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);


-- ============================================================================
-- Source: 039_master_data_linkage_rules.sql
-- ============================================================================
-- Harden master data linkage rules for product categories, brand categories,
-- brands, products, SKUs, warehouses, and stock filters.
-- Safe to run repeatedly.

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS exec_if_table_exists;

DELIMITER $$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE exec_if_table_exists(
    IN p_table_name VARCHAR(64),
    IN p_sql TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) THEN
        SET @ddl = p_sql;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_index_if_missing('brand_category_product_categories', 'idx_bcpc_product_brand_category', '`product_category_id`, `brand_category_id`');
CALL add_index_if_missing('brand_product_categories', 'idx_bpc_product_brand', '`product_category_id`, `brand_id`');

CALL add_index_if_missing('brands', 'idx_brands_category_status', '`brand_category_id`, `status`, `deleted_at`');
CALL add_index_if_missing('products', 'idx_products_taxonomy', '`product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('products', 'idx_products_brand_category_brand', '`brand_category_id`, `brand_id`');
CALL add_index_if_missing('products', 'idx_products_category_status', '`product_category_id`, `status`, `deleted_at`');
CALL add_index_if_missing('skus', 'idx_skus_taxonomy', '`product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_product_taxonomy', '`product_id`, `product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_status_taxonomy', '`status`, `product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_product_sku_wh', '`product_id`, `sku_id`, `warehouse_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_warehouse_product', '`warehouse_id`, `product_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_sku_stock', '`sku_id`, `stock_qty`, `available_qty`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_warehouse_created', '`warehouse_id`, `created_at`');
CALL add_index_if_missing('quotation_items', 'idx_quotation_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('sales_order_items', 'idx_sales_order_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('purchase_order_items', 'idx_purchase_order_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_inbound_order_items', 'idx_inbound_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_outbound_order_items', 'idx_outbound_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('serial_numbers', 'idx_serial_numbers_product_sku_wh', '`product_id`, `sku_id`, `warehouse_id`');
CALL add_index_if_missing('serial_numbers', 'idx_serial_numbers_sku_status_wh', '`sku_id`, `status`, `warehouse_id`');
CALL add_index_if_missing('inventory_check_orders', 'idx_inventory_check_filter', '`warehouse_id`, `product_category_id`, `brand_category_id`, `brand_id`, `status`');
CALL add_index_if_missing('inventory_check_items', 'idx_inventory_check_item_filter', '`warehouse_id`, `product_category_id`, `brand_category_id`, `brand_id`, `sku_id`');

-- Linkage tables are maintained as current-state rule sets. Physically remove
-- soft-deleted or orphaned rows so unique keys do not block re-adding a rule.
DELETE bcpc
FROM brand_category_product_categories bcpc
LEFT JOIN brand_categories bc ON bc.id = bcpc.brand_category_id
LEFT JOIN product_categories pc ON pc.id = bcpc.product_category_id
WHERE bcpc.deleted_at IS NOT NULL
   OR bcpc.brand_category_id = 0
   OR bcpc.product_category_id = 0
   OR bc.id IS NULL
   OR pc.id IS NULL
   OR bc.deleted_at IS NOT NULL
   OR pc.deleted_at IS NOT NULL;

DELETE bpc
FROM brand_product_categories bpc
LEFT JOIN brands b ON b.id = bpc.brand_id
LEFT JOIN product_categories pc ON pc.id = bpc.product_category_id
WHERE bpc.deleted_at IS NOT NULL
   OR bpc.brand_id = 0
   OR bpc.product_category_id = 0
   OR b.id IS NULL
   OR pc.id IS NULL
   OR b.deleted_at IS NOT NULL
   OR pc.deleted_at IS NOT NULL;

-- Backfill missing applicable product-category scopes from existing business data.
INSERT IGNORE INTO brand_category_product_categories (brand_category_id, product_category_id)
SELECT DISTINCT b.brand_category_id, bpc.product_category_id
FROM brands b
JOIN brand_product_categories bpc ON bpc.brand_id = b.id
WHERE b.deleted_at IS NULL
  AND b.brand_category_id > 0
  AND bpc.product_category_id > 0;

INSERT IGNORE INTO brand_category_product_categories (brand_category_id, product_category_id)
SELECT DISTINCT p.brand_category_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_category_id > 0
  AND p.product_category_id > 0;

INSERT IGNORE INTO brand_product_categories (brand_id, product_category_id)
SELECT DISTINCT p.brand_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0
  AND p.product_category_id > 0;

-- For brands that have no explicit scope rows, inherit the product-category
-- scope from their brand category so existing migrated brands remain usable.
INSERT IGNORE INTO brand_product_categories (brand_id, product_category_id)
SELECT DISTINCT b.id, bcpc.product_category_id
FROM brands b
JOIN brand_category_product_categories bcpc ON bcpc.brand_category_id = b.brand_category_id
LEFT JOIN brand_product_categories existing ON existing.brand_id = b.id
WHERE b.deleted_at IS NULL
  AND b.id > 0
  AND b.brand_category_id > 0
  AND bcpc.product_category_id > 0
  AND existing.id IS NULL;

-- Ensure product and SKU taxonomy snapshots follow the selected brand.
UPDATE products p
JOIN brands b ON b.id = p.brand_id
SET p.brand = b.brand_name,
    p.brand_category_id = b.brand_category_id,
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0
  AND (BINARY p.brand <> BINARY b.brand_name OR p.brand_category_id <> b.brand_category_id);

UPDATE products p
JOIN product_categories pc ON pc.id = p.product_category_id
SET p.category = pc.category_name,
    p.unit = IF(p.unit = '', pc.default_unit, p.unit),
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.product_category_id > 0
  AND (BINARY p.category <> BINARY pc.category_name OR (p.unit = '' AND pc.default_unit <> ''));

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.model = IF(s.model = '', p.model, s.model),
    s.is_stock_item = p.is_stock_item,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL
  AND (
      s.product_category_id <> p.product_category_id
      OR s.brand_category_id <> p.brand_category_id
      OR s.brand_id <> p.brand_id
      OR (BINARY s.model = BINARY '' AND BINARY p.model <> BINARY '')
      OR s.is_stock_item <> p.is_stock_item
  );

UPDATE inventory_stocks ist
JOIN skus s ON s.id = ist.sku_id
SET ist.product_id = s.product_id,
    ist.updated_at = CURRENT_TIMESTAMP
WHERE ist.product_id <> s.product_id;

UPDATE inventory_records ir
JOIN skus s ON s.id = ir.sku_id
SET ir.product_id = s.product_id
WHERE ir.product_id <> s.product_id;

UPDATE quotation_items qi
JOIN skus s ON s.id = qi.sku_id
SET qi.product_id = s.product_id,
    qi.updated_at = CURRENT_TIMESTAMP
WHERE qi.product_id <> s.product_id;

UPDATE sales_order_items soi
JOIN skus s ON s.id = soi.sku_id
SET soi.product_id = s.product_id,
    soi.updated_at = CURRENT_TIMESTAMP
WHERE soi.product_id <> s.product_id;

UPDATE purchase_order_items poi
JOIN skus s ON s.id = poi.sku_id
SET poi.product_id = s.product_id,
    poi.updated_at = CURRENT_TIMESTAMP
WHERE poi.product_id <> s.product_id;

UPDATE inventory_inbound_order_items ioi
JOIN skus s ON s.id = ioi.sku_id
SET ioi.product_id = s.product_id,
    ioi.updated_at = CURRENT_TIMESTAMP
WHERE ioi.product_id <> s.product_id;

UPDATE inventory_outbound_order_items ooi
JOIN skus s ON s.id = ooi.sku_id
SET ooi.product_id = s.product_id,
    ooi.updated_at = CURRENT_TIMESTAMP
WHERE ooi.product_id <> s.product_id;

UPDATE serial_numbers sn
JOIN skus s ON s.id = sn.sku_id
SET sn.product_id = s.product_id,
    sn.updated_at = CURRENT_TIMESTAMP
WHERE sn.product_id <> s.product_id;

CALL exec_if_table_exists('inventory_check_orders', 'UPDATE inventory_check_orders ico JOIN warehouses w ON w.id = ico.warehouse_id SET ico.warehouse_name = w.name, ico.updated_at = CURRENT_TIMESTAMP WHERE BINARY ico.warehouse_name <> BINARY w.name');

CALL exec_if_table_exists('inventory_check_items', 'UPDATE inventory_check_items ici JOIN skus s ON s.id = ici.sku_id LEFT JOIN products p ON p.id = s.product_id LEFT JOIN product_categories pc ON pc.id = s.product_category_id LEFT JOIN brand_categories bc ON bc.id = s.brand_category_id LEFT JOIN brands b ON b.id = s.brand_id LEFT JOIN warehouses w ON w.id = ici.warehouse_id SET ici.product_id = s.product_id, ici.product_name = COALESCE(p.name, ici.product_name), ici.product_category_id = s.product_category_id, ici.product_category_name = COALESCE(pc.category_name, ''''), ici.brand_category_id = s.brand_category_id, ici.brand_category_name = COALESCE(bc.category_name, ''''), ici.brand_id = s.brand_id, ici.brand_name = COALESCE(b.brand_name, ''''), ici.model = IF(ici.model = '''', s.model, ici.model), ici.warehouse_name = COALESCE(w.name, ici.warehouse_name), ici.updated_at = CURRENT_TIMESTAMP WHERE ici.product_id <> s.product_id OR ici.product_category_id <> s.product_category_id OR ici.brand_category_id <> s.brand_category_id OR ici.brand_id <> s.brand_id OR (pc.category_name IS NOT NULL AND BINARY ici.product_category_name <> BINARY pc.category_name) OR (bc.category_name IS NOT NULL AND BINARY ici.brand_category_name <> BINARY bc.category_name) OR (b.brand_name IS NOT NULL AND BINARY ici.brand_name <> BINARY b.brand_name) OR (w.name IS NOT NULL AND BINARY ici.warehouse_name <> BINARY w.name) OR (BINARY ici.model = BINARY '''' AND BINARY s.model <> BINARY '''')');

-- Number-rule records for master data objects. Product/SKU code generation still
-- uses the business naming rule in code unless the module is later switched to
-- the shared number generator.
INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('product_category', '商品分类编号', 'FL', '20060102', 4, 'active', '商品分类编码规则预置'),
('brand_category', '品牌分类编号', 'PL', '20060102', 4, 'active', '品牌分类编码规则预置'),
('brand', '品牌编号', 'PP', '20060102', 4, 'active', '品牌编码规则预置'),
('product', '商品编号', 'SP', '20060102', 4, 'active', '商品编码规则预置'),
('sku', 'SKU编号', 'SKU', '20060102', 4, 'active', 'SKU编码规则预置'),
('warehouse', '仓库编号', 'CK', '20060102', 4, 'active', '仓库编码规则预置')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);

-- Keep common operating roles able to query master data needed by linkage filters.
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'productCategory:list',
    'brandCategory:list',
    'brand:list',
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list'
)
WHERE r.code IN (
    'super_admin',
    'boss',
    'product_admin',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'warehouse_manager',
    'finance',
    'auditor'
);

-- 038 creates the inventory check menu and APIs; this migration makes the
-- feature visible and usable for existing operating roles after a full import
-- or after replaying only the latest migrations.
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('inventory', 'inventoryChecks')
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'inventory:check:list'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:check:create',
    'inventory:check:update',
    'inventory:check:start',
    'inventory:check:submit',
    'inventory:check:export',
    'inventory:check:print'
)
WHERE r.code IN (
    'super_admin',
    'admin',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:check:delete',
    'inventory:check:audit',
    'inventory:check:reject',
    'inventory:check:adjust',
    'inventory:check:cancel'
)
WHERE r.code IN (
    'super_admin',
    'admin',
    'warehouse_manager',
    'warehouse_admin'
);

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS exec_if_table_exists;


-- ============================================================================
-- Source: 040_phase1_business_closure.sql
-- ============================================================================
-- Phase 1 business closure hardening: persistent stock checks,
-- shortage purchasing status, and business rule settings.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('sales_orders', 'stock_check_status', 'VARCHAR(32) NOT NULL DEFAULT ''unchecked''', 'status');
CALL add_column_if_missing('sales_orders', 'shortage_status', 'VARCHAR(32) NOT NULL DEFAULT ''unchecked''', 'stock_check_status');
CALL add_column_if_missing('sales_orders', 'purchase_status', 'VARCHAR(32) NOT NULL DEFAULT ''none''', 'shortage_status');
CALL add_column_if_missing('sales_orders', 'stock_check_warehouse_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'purchase_status');
CALL add_column_if_missing('sales_orders', 'stock_checked_at', 'DATETIME NULL', 'stock_check_warehouse_id');

CALL add_index_if_missing('sales_orders', 'idx_sales_orders_stock_check_status', '`stock_check_status`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_shortage_purchase', '`shortage_status`, `purchase_status`');

CREATE TABLE IF NOT EXISTS sales_order_stock_checks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sales_order_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL DEFAULT '',
    order_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    shipped_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    required_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    available_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    shortage_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    need_purchase TINYINT(1) NOT NULL DEFAULT 0,
    purchased_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    inbound_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_sales_stock_check_order (sales_order_id, line_no),
    KEY idx_sales_stock_check_sku (sku_id),
    KEY idx_sales_stock_check_shortage (sales_order_id, need_purchase, shortage_qty)
);

CALL add_column_if_missing('system_app_settings', 'enable_quotation_approval', 'TINYINT(1) NOT NULL DEFAULT 1', 'logo_url');
CALL add_column_if_missing('system_app_settings', 'enable_sales_approval', 'TINYINT(1) NOT NULL DEFAULT 1', 'enable_quotation_approval');
CALL add_column_if_missing('system_app_settings', 'enable_purchase_approval', 'TINYINT(1) NOT NULL DEFAULT 1', 'enable_sales_approval');
CALL add_column_if_missing('system_app_settings', 'allow_negative_stock', 'TINYINT(1) NOT NULL DEFAULT 0', 'enable_purchase_approval');
CALL add_column_if_missing('system_app_settings', 'enable_stock_reservation', 'TINYINT(1) NOT NULL DEFAULT 0', 'allow_negative_stock');
CALL add_column_if_missing('system_app_settings', 'allow_sales_view_stock', 'TINYINT(1) NOT NULL DEFAULT 1', 'enable_stock_reservation');
CALL add_column_if_missing('system_app_settings', 'require_contract_before_outbound', 'TINYINT(1) NOT NULL DEFAULT 0', 'allow_sales_view_stock');
CALL add_column_if_missing('system_app_settings', 'default_upload_max_mb', 'INT NOT NULL DEFAULT 50', 'require_contract_before_outbound');
CALL add_column_if_missing('system_app_settings', 'default_export_max_rows', 'INT NOT NULL DEFAULT 5000', 'default_upload_max_mb');

UPDATE system_app_settings
SET enable_quotation_approval = 1,
    enable_sales_approval = 1,
    enable_purchase_approval = 1,
    allow_negative_stock = 0,
    allow_sales_view_stock = 1
WHERE id = 1;

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 041_fix_admin_default_password.sql
-- ============================================================================
-- Fix the default admin password hash.
-- The previous seed hash does not match the documented default password:
-- username: admin
-- password: admin123

UPDATE users
SET password_hash = '$2a$10$yOcqosM6UTLC1GWy0lM/9.R742LAQkGzK26MSI3ICK/QRXhzZ3y36',
    status = 'active',
    deleted_at = NULL
WHERE username = 'admin'
  AND password_hash = '$2a$10$cHJ9BT8U1pqavd4LAMREA.enboTE.v/PebsWwad3Z5GEgFIfenp7i';


-- ============================================================================
-- Source: 042_system_license.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS sys_license (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    license_no VARCHAR(100) NOT NULL COMMENT '授权编号',
    customer_name VARCHAR(200) NOT NULL COMMENT '授权客户名称',
    product_name VARCHAR(100) NOT NULL COMMENT '产品名称',
    edition VARCHAR(50) NOT NULL COMMENT '授权版本 trial/standard/professional/enterprise',
    machine_code VARCHAR(255) NOT NULL COMMENT '授权机器码',
    current_machine_code VARCHAR(255) NULL COMMENT '当前机器码',
    start_date DATE NOT NULL COMMENT '授权开始日期',
    expire_date DATE NOT NULL COMMENT '授权到期日期',
    max_users INT NOT NULL DEFAULT 0 COMMENT '最大启用用户数',
    max_orgs INT NULL COMMENT '最大机构数',
    max_warehouses INT NULL COMMENT '最大仓库数',
    modules JSON NULL COMMENT '授权模块',
    features JSON NULL COMMENT '授权功能',
    license_content JSON NOT NULL COMMENT '授权内容',
    signature TEXT NOT NULL COMMENT '授权签名',
    status VARCHAR(30) NOT NULL DEFAULT 'valid' COMMENT 'valid/expired/invalid/mismatch/not_found/disabled',
    uploaded_by BIGINT NULL COMMENT '上传人',
    uploaded_at DATETIME NULL COMMENT '上传时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_license_no (license_no),
    INDEX idx_status (status),
    INDEX idx_expire_date (expire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统授权表';

CREATE TABLE IF NOT EXISTS sys_license_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(50) NOT NULL COMMENT '操作类型 upload/verify/refresh/warning/expire',
    license_no VARCHAR(100) NULL COMMENT '授权编号',
    status VARCHAR(30) NOT NULL COMMENT 'success/failed',
    message VARCHAR(1000) NULL COMMENT '日志内容',
    operator_id BIGINT NULL COMMENT '操作人ID',
    operator_name VARCHAR(100) NULL COMMENT '操作人名称',
    ip VARCHAR(100) NULL COMMENT 'IP地址',
    user_agent VARCHAR(500) NULL COMMENT 'User-Agent',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license_no (license_no),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统授权日志表';

UPDATE menus
SET parent_id = 44,
    name = 'financeReport',
    path = 'finance',
    component = '/reports/finance/index',
    redirect = '',
    title = '财务报表',
    icon = 'Money',
    sort = 4
WHERE id = 64;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (65, 2, 'systemLicense', 'license', '/system/license/index', '', '系统授权', 'Key', 12)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:license:view', '系统授权查看', 'api', 'system', '/api/v1/system/license/status', 'GET', 1970, 'active'),
('system:license:upload', '系统授权上传', 'api', 'system', '/api/v1/system/license/upload', 'POST', 1971, 'active'),
('system:license:refresh', '系统授权刷新', 'api', 'system', '/api/v1/system/license/refresh', 'POST', 1972, 'active'),
('system:license:logs', '系统授权日志', 'api', 'system', '/api/v1/system/license/logs', 'GET', 1973, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'systemLicense'
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('system:license:view', 'system:license:upload', 'system:license:refresh', 'system:license:logs')
WHERE r.code IN ('super_admin', 'admin', 'boss');


-- ============================================================================
-- Source: 043_system_impersonation.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS sys_impersonation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_user_id BIGINT NOT NULL COMMENT '原始操作人ID',
    original_username VARCHAR(100) NOT NULL COMMENT '原始操作人账号',
    target_user_id BIGINT NOT NULL COMMENT '被代登录用户ID',
    target_username VARCHAR(100) NOT NULL COMMENT '被代登录用户账号',
    reason VARCHAR(500) NOT NULL COMMENT '代登录原因',
    mode VARCHAR(30) NOT NULL DEFAULT 'readonly' COMMENT 'readonly/operation',
    login_ip VARCHAR(100) NULL COMMENT 'IP地址',
    user_agent VARCHAR(500) NULL COMMENT '浏览器信息',
    started_at DATETIME NOT NULL COMMENT '开始时间',
    ended_at DATETIME NULL COMMENT '结束时间',
    status VARCHAR(30) NOT NULL DEFAULT 'active' COMMENT 'active/exited/expired',
    created_at DATETIME NOT NULL,
    INDEX idx_original_user_id (original_user_id),
    INDEX idx_target_user_id (target_user_id),
    INDEX idx_started_at (started_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代登录日志表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:user:impersonate', '代登录用户', 'api', 'system', '/api/v1/system/users/:id/impersonate', 'POST', 108, 'active'),
('system:user:impersonateSubordinate', '代登录下级用户', 'api', 'system', '/api/v1/system/users/:id/impersonate-subordinate', 'POST', 109, 'active'),
('system:user:viewSubordinate', '查看下级用户', 'api', 'system', '/api/v1/system/users/subordinates', 'GET', 110, 'active'),
('system:user:impersonateLog', '代登录日志', 'api', 'system', '/api/v1/system/impersonation-logs', 'GET', 111, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:user:impersonate',
    'system:user:impersonateSubordinate',
    'system:user:viewSubordinate',
    'system:user:impersonateLog'
)
WHERE r.code IN ('super_admin', 'admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:user:impersonateSubordinate',
    'system:user:viewSubordinate'
)
WHERE r.code IN ('sales_manager', 'sales_leader', 'department_leader', 'team_leader');


-- ============================================================================
-- Source: 044_erp15_three_line_closure.sql
-- ============================================================================
-- ERP 1.5: three-line closure foundation.
-- Adds document relations plus sales returns, purchase returns, and inventory adjustments.

CREATE TABLE IF NOT EXISTS biz_relations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    source_type VARCHAR(64) NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    target_type VARCHAR(64) NOT NULL,
    target_id BIGINT UNSIGNED NOT NULL,
    target_no VARCHAR(64) NOT NULL DEFAULT '',
    relation_type VARCHAR(64) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_biz_rel_source (source_type, source_id),
    KEY idx_biz_rel_target (target_type, target_id),
    KEY idx_biz_rel_relation_type (relation_type)
);

CREATE TABLE IF NOT EXISTS inventory_sales_return_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    return_no VARCHAR(64) NOT NULL UNIQUE,
    source_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_outbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_sales_return_sales (source_sales_order_id),
    KEY idx_sales_return_outbound (source_outbound_order_id),
    KEY idx_sales_return_warehouse_status (warehouse_id, status),
    KEY idx_sales_return_customer_status (customer_id, status),
    KEY idx_sales_return_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_sales_return_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sales_return_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_price DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_sales_return_items_order (sales_return_order_id),
    KEY idx_sales_return_items_product_sku (product_id, sku_id)
);

CREATE TABLE IF NOT EXISTS inventory_purchase_return_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    return_no VARCHAR(64) NOT NULL UNIQUE,
    source_purchase_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_inbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_purchase_return_purchase (source_purchase_order_id),
    KEY idx_purchase_return_inbound (source_inbound_order_id),
    KEY idx_purchase_return_warehouse_status (warehouse_id, status),
    KEY idx_purchase_return_supplier_status (supplier_id, status),
    KEY idx_purchase_return_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_purchase_return_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    purchase_return_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_purchase_return_items_order (purchase_return_order_id),
    KEY idx_purchase_return_items_product_sku (product_id, sku_id)
);

CREATE TABLE IF NOT EXISTS inventory_adjustment_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    adjustment_no VARCHAR(64) NOT NULL UNIQUE,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    adjustment_type VARCHAR(32) NOT NULL DEFAULT 'other',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    submit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    submit_time DATETIME NULL,
    audit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    audit_time DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_adjustment_warehouse_status (warehouse_id, status),
    KEY idx_adjustment_type_status (adjustment_type, status),
    KEY idx_adjustment_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_adjustment_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    adjustment_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    change_direction VARCHAR(16) NOT NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_adjustment_items_order (adjustment_order_id),
    KEY idx_adjustment_items_product_sku (product_id, sku_id)
);

CREATE TABLE IF NOT EXISTS serial_number_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sn_id BIGINT UNSIGNED NOT NULL,
    sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL,
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sn_records_sn_id (sn_id),
    KEY idx_sn_records_sn_code (sn_code),
    KEY idx_sn_records_biz (biz_type, biz_id),
    KEY idx_sn_records_created_at (created_at)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS finance_return_adjustments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    adjustment_no VARCHAR(64) NOT NULL UNIQUE,
    adjustment_type VARCHAR(32) NOT NULL,
    biz_type VARCHAR(64) NOT NULL,
    biz_id BIGINT UNSIGNED NOT NULL,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    source_type VARCHAR(64) NOT NULL DEFAULT '',
    source_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    counterparty_type VARCHAR(32) NOT NULL DEFAULT '',
    counterparty_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    receivable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    payable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    offset_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    refund_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_fin_return_adjust_biz (biz_type, biz_id),
    KEY idx_fin_return_adjust_source (source_type, source_id),
    KEY idx_fin_return_adjust_receivable (receivable_id),
    KEY idx_fin_return_adjust_payable (payable_id),
    KEY idx_fin_return_adjust_counterparty (counterparty_type, counterparty_id),
    KEY idx_fin_return_adjust_status (status),
    KEY idx_fin_return_adjust_deleted_at (deleted_at)
);

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('inventory_adjustment_orders', 'submit_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'remark');
CALL add_column_if_missing('inventory_adjustment_orders', 'submit_time', 'DATETIME NULL', 'submit_user_id');
CALL add_column_if_missing('inventory_adjustment_orders', 'audit_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'submit_time');
CALL add_column_if_missing('inventory_adjustment_orders', 'audit_time', 'DATETIME NULL', 'audit_user_id');

DROP PROCEDURE IF EXISTS add_column_if_missing;

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('sales_return', 'Sales Return', 'XSTH', '20060102', 4, 'active', ''),
('purchase_return', 'Purchase Return', 'CGTH', '20060102', 4, 'active', ''),
('inventory_adjust', 'Inventory Adjustment', 'TZ', '20060102', 4, 'active', ''),
('finance_return_adjust', 'Return Finance Adjustment', 'THTZ', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('inventory:salesReturn:list', 'List sales return orders', 'api', 'inventory', '/api/v1/inventory/sales-return-orders', 'GET', 1061, 'active'),
('inventory:salesReturn:create', 'Create sales return orders', 'api', 'inventory', '/api/v1/inventory/sales-return-orders', 'POST', 1062, 'active'),
('inventory:salesReturn:update', 'Update sales return orders', 'api', 'inventory', '/api/v1/inventory/sales-return-orders/:id', 'PUT', 1063, 'active'),
('inventory:salesReturn:confirm', 'Confirm sales returns', 'api', 'inventory', '/api/v1/inventory/sales-return-orders/:id/confirm', 'POST', 1064, 'active'),
('inventory:salesReturn:cancel', 'Cancel sales return orders', 'api', 'inventory', '/api/v1/inventory/sales-return-orders/:id/cancel', 'POST', 1065, 'active'),
('inventory:purchaseReturn:list', 'List purchase return orders', 'api', 'inventory', '/api/v1/inventory/purchase-return-orders', 'GET', 1066, 'active'),
('inventory:purchaseReturn:create', 'Create purchase return orders', 'api', 'inventory', '/api/v1/inventory/purchase-return-orders', 'POST', 1067, 'active'),
('inventory:purchaseReturn:update', 'Update purchase return orders', 'api', 'inventory', '/api/v1/inventory/purchase-return-orders/:id', 'PUT', 1068, 'active'),
('inventory:purchaseReturn:confirm', 'Confirm purchase returns', 'api', 'inventory', '/api/v1/inventory/purchase-return-orders/:id/confirm', 'POST', 1069, 'active'),
('inventory:purchaseReturn:cancel', 'Cancel purchase return orders', 'api', 'inventory', '/api/v1/inventory/purchase-return-orders/:id/cancel', 'POST', 1070, 'active'),
('inventory:adjustment:list', 'List inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders', 'GET', 1071, 'active'),
('inventory:adjustment:create', 'Create inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders', 'POST', 1072, 'active'),
('inventory:adjustment:update', 'Update inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id', 'PUT', 1073, 'active'),
('inventory:adjustment:submit', 'Submit inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id/submit', 'POST', 1074, 'active'),
('inventory:adjustment:audit', 'Audit inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id/audit', 'POST', 1075, 'active'),
('inventory:adjustment:reject', 'Reject inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id/reject', 'POST', 1076, 'active'),
('inventory:adjustment:confirm', 'Confirm inventory adjustments', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id/confirm', 'POST', 1077, 'active'),
('inventory:adjustment:cancel', 'Cancel inventory adjustment orders', 'api', 'inventory', '/api/v1/inventory/adjustment-orders/:id/cancel', 'POST', 1078, 'active'),
('inventory:returnAdjust:attachment', 'Manage return and adjustment attachments', 'button', 'inventory', '', '', 1079, 'active'),
('biz_relation:list', 'List business document relations', 'api', 'base', '/api/v1/biz-relations', 'GET', 1301, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN (
    'inventory:salesReturn:list',
    'inventory:salesReturn:create',
    'inventory:salesReturn:update',
    'inventory:salesReturn:confirm',
    'inventory:salesReturn:cancel',
    'inventory:purchaseReturn:list',
    'inventory:purchaseReturn:create',
    'inventory:purchaseReturn:update',
    'inventory:purchaseReturn:confirm',
    'inventory:purchaseReturn:cancel',
    'inventory:adjustment:list',
    'inventory:adjustment:create',
    'inventory:adjustment:update',
    'inventory:adjustment:submit',
    'inventory:adjustment:audit',
    'inventory:adjustment:reject',
    'inventory:adjustment:confirm',
    'inventory:adjustment:cancel',
    'inventory:returnAdjust:attachment',
    'biz_relation:list'
);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 66, id, 'salesReturnOrders', 'sales-return-orders', '/inventory/sales-return-orders/index', '', '销售退货单', 'RefreshLeft', 6
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 67, id, 'purchaseReturnOrders', 'purchase-return-orders', '/inventory/purchase-return-orders/index', '', '采购退货单', 'RefreshRight', 7
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 68, id, 'inventoryAdjustments', 'adjustment-orders', '/inventory/adjustment-orders/index', '', '库存调整单', 'Operation', 8
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 69, id, 'bizRelations', 'relations', '/inventory/relations/index', '', '单据关系', 'Connection', 9
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus
WHERE id IN (66, 67, 68, 69);


-- ============================================================================
-- Source: 045_inventory_phase1_state_closure.sql
-- ============================================================================
-- Inventory phase 1 state closure: frozen/in-transit/scrap quantities,
-- freeze/unfreeze orders, transfer orders, and traceable SN import status.

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('inventory_stocks', 'frozen_qty', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'locked_qty');
CALL add_column_if_missing('inventory_stocks', 'in_transit_qty', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'frozen_qty');
CALL add_column_if_missing('inventory_stocks', 'scrap_qty', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'in_transit_qty');

UPDATE inventory_stocks
SET available_qty = GREATEST(stock_qty - locked_qty - frozen_qty - scrap_qty, 0);

CREATE TABLE IF NOT EXISTS inventory_freeze_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    freeze_no VARCHAR(64) NOT NULL UNIQUE,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    action_type VARCHAR(16) NOT NULL,
    reason_type VARCHAR(32) NOT NULL DEFAULT 'other',
    total_quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_freeze_warehouse_status (warehouse_id, status),
    KEY idx_freeze_action_reason (action_type, reason_type),
    KEY idx_freeze_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_freeze_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    freeze_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_freeze_items_order (freeze_order_id),
    KEY idx_freeze_items_product_sku (product_id, sku_id)
);

CREATE TABLE IF NOT EXISTS inventory_transfer_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    transfer_no VARCHAR(64) NOT NULL UNIQUE,
    from_warehouse_id BIGINT UNSIGNED NOT NULL,
    to_warehouse_id BIGINT UNSIGNED NOT NULL,
    total_quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    out_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    out_time DATETIME NULL,
    in_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    in_time DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_transfer_from_status (from_warehouse_id, status),
    KEY idx_transfer_to_status (to_warehouse_id, status),
    KEY idx_transfer_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS inventory_transfer_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    transfer_order_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL,
    sku_name VARCHAR(128) NOT NULL,
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit VARCHAR(32) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_transfer_items_order (transfer_order_id),
    KEY idx_transfer_items_product_sku (product_id, sku_id)
);

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('inventory_freeze', 'Inventory Freeze', 'DJ', '20060102', 4, 'active', ''),
('inventory_transfer', 'Inventory Transfer', 'DB', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('inventory:freeze:list', 'List inventory freeze orders', 'api', 'inventory', '/api/v1/inventory/freeze-orders', 'GET', 1081, 'active'),
('inventory:freeze:create', 'Create inventory freeze orders', 'api', 'inventory', '/api/v1/inventory/freeze-orders', 'POST', 1082, 'active'),
('inventory:freeze:update', 'Update inventory freeze orders', 'api', 'inventory', '/api/v1/inventory/freeze-orders/:id', 'PUT', 1083, 'active'),
('inventory:freeze:confirm', 'Confirm inventory freeze orders', 'api', 'inventory', '/api/v1/inventory/freeze-orders/:id/confirm', 'POST', 1084, 'active'),
('inventory:freeze:cancel', 'Cancel inventory freeze orders', 'api', 'inventory', '/api/v1/inventory/freeze-orders/:id/cancel', 'POST', 1085, 'active'),
('inventory:transfer:list', 'List inventory transfer orders', 'api', 'inventory', '/api/v1/inventory/transfer-orders', 'GET', 1091, 'active'),
('inventory:transfer:create', 'Create inventory transfer orders', 'api', 'inventory', '/api/v1/inventory/transfer-orders', 'POST', 1092, 'active'),
('inventory:transfer:update', 'Update inventory transfer orders', 'api', 'inventory', '/api/v1/inventory/transfer-orders/:id', 'PUT', 1093, 'active'),
('inventory:transfer:out', 'Confirm inventory transfer outbound', 'api', 'inventory', '/api/v1/inventory/transfer-orders/:id/confirm-out', 'POST', 1094, 'active'),
('inventory:transfer:in', 'Confirm inventory transfer inbound', 'api', 'inventory', '/api/v1/inventory/transfer-orders/:id/confirm-in', 'POST', 1095, 'active'),
('inventory:transfer:cancel', 'Cancel inventory transfer orders', 'api', 'inventory', '/api/v1/inventory/transfer-orders/:id/cancel', 'POST', 1096, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN (
    'inventory:freeze:list',
    'inventory:freeze:create',
    'inventory:freeze:update',
    'inventory:freeze:confirm',
    'inventory:freeze:cancel',
    'inventory:transfer:list',
    'inventory:transfer:create',
    'inventory:transfer:update',
    'inventory:transfer:out',
    'inventory:transfer:in',
    'inventory:transfer:cancel'
);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 70, id, 'inventoryFreezeOrders', 'freeze-orders', '/inventory/freeze-orders/index', '', '库存冻结/解冻', 'Lock', 10
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 71, id, 'inventoryTransferOrders', 'transfer-orders', '/inventory/transfer-orders/index', '', '库存调拨', 'Switch', 11
FROM menus
WHERE name = 'inventory'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus
WHERE id IN (70, 71);

DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 046_finance_phase2_closure.sql
-- ============================================================================
-- Finance phase 2 closure: reconciliation, aging, invoices, expenses, and transfer cost carry.

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('inventory_outbound_order_items', 'unit_cost', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('inventory_transfer_order_items', 'unit_cost', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'quantity');

CREATE TABLE IF NOT EXISTS finance_invoices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    invoice_no VARCHAR(64) NOT NULL UNIQUE,
    invoice_type VARCHAR(32) NOT NULL,
    source_type VARCHAR(64) NOT NULL DEFAULT '',
    source_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    counterparty_type VARCHAR(32) NOT NULL DEFAULT '',
    counterparty_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    counterparty_name VARCHAR(128) NOT NULL DEFAULT '',
    receivable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    payable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    receipt_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    payment_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    invoice_date DATE NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'issued',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_fin_invoice_type_status (invoice_type, status),
    KEY idx_fin_invoice_counterparty (counterparty_type, counterparty_id),
    KEY idx_fin_invoice_source (source_type, source_id),
    KEY idx_fin_invoice_receivable (receivable_id),
    KEY idx_fin_invoice_payable (payable_id),
    KEY idx_fin_invoice_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS finance_expense_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    expense_no VARCHAR(64) NOT NULL UNIQUE,
    expense_type VARCHAR(64) NOT NULL,
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    bearer_type VARCHAR(32) NOT NULL DEFAULT '',
    bearer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    bearer_name VARCHAR(128) NOT NULL DEFAULT '',
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    include_cost TINYINT(1) NOT NULL DEFAULT 0,
    attachment_file_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_fin_expense_type_status (expense_type, status),
    KEY idx_fin_expense_biz (biz_type, biz_id),
    KEY idx_fin_expense_bearer (bearer_type, bearer_id),
    KEY idx_fin_expense_include_cost (include_cost),
    KEY idx_fin_expense_deleted_at (deleted_at)
);

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('finance_invoice', 'Finance Invoice', 'FP', '20060102', 4, 'active', ''),
('finance_expense', 'Finance Expense', 'FY', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:reconciliation:customer', 'Customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation', 'GET', 1351, 'active'),
('finance:reconciliation:customer:export', 'Export customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation/export', 'GET', 1352, 'active'),
('finance:reconciliation:customer:print', 'Print customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation/print', 'GET', 1353, 'active'),
('finance:reconciliation:supplier', 'Supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation', 'GET', 1354, 'active'),
('finance:reconciliation:supplier:export', 'Export supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation/export', 'GET', 1355, 'active'),
('finance:reconciliation:supplier:print', 'Print supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation/print', 'GET', 1356, 'active'),
('finance:aging:receivable', 'Receivable aging', 'api', 'finance', '/api/v1/finance/receivables/aging', 'GET', 1361, 'active'),
('finance:aging:payable', 'Payable aging', 'api', 'finance', '/api/v1/finance/payables/aging', 'GET', 1362, 'active'),
('finance:invoice:list', 'List finance invoices', 'api', 'finance', '/api/v1/finance/invoices', 'GET', 1371, 'active'),
('finance:invoice:create', 'Create finance invoices', 'api', 'finance', '/api/v1/finance/invoices', 'POST', 1372, 'active'),
('finance:invoice:update', 'Update finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id', 'PUT', 1373, 'active'),
('finance:invoice:cancel', 'Cancel finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/cancel', 'POST', 1374, 'active'),
('finance:expense:list', 'List finance expenses', 'api', 'finance', '/api/v1/finance/expenses', 'GET', 1381, 'active'),
('finance:expense:create', 'Create finance expenses', 'api', 'finance', '/api/v1/finance/expenses', 'POST', 1382, 'active'),
('finance:expense:update', 'Update finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id', 'PUT', 1383, 'active'),
('finance:expense:confirm', 'Confirm finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/confirm', 'POST', 1384, 'active'),
('finance:expense:cancel', 'Cancel finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/cancel', 'POST', 1385, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'finance:reconciliation:customer',
    'finance:reconciliation:customer:export',
    'finance:reconciliation:customer:print',
    'finance:reconciliation:supplier',
    'finance:reconciliation:supplier:export',
    'finance:reconciliation:supplier:print',
    'finance:aging:receivable',
    'finance:aging:payable',
    'finance:invoice:list',
    'finance:invoice:create',
    'finance:invoice:update',
    'finance:invoice:cancel',
    'finance:expense:list',
    'finance:expense:create',
    'finance:expense:update',
    'finance:expense:confirm',
    'finance:expense:cancel'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 72, id, 'customerReconciliation', 'customer-reconciliation', '/finance/customer-reconciliation/index', '', '客户对账', 'Connection', 5
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 73, id, 'supplierReconciliation', 'supplier-reconciliation', '/finance/supplier-reconciliation/index', '', '供应商对账', 'Connection', 6
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 74, id, 'receivableAging', 'receivable-aging', '/finance/receivable-aging/index', '', '应收账龄', 'Timer', 7
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 75, id, 'payableAging', 'payable-aging', '/finance/payable-aging/index', '', '应付账龄', 'Timer', 8
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 76, id, 'financeInvoices', 'invoices', '/finance/invoices/index', '', '发票管理', 'Tickets', 9
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 77, id, 'financeExpenses', 'expenses', '/finance/expenses/index', '', '费用挂单', 'Money', 10
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (72, 73, 74, 75, 76, 77)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 047_finance_invoice_expense_audit.sql
-- ============================================================================
-- Finance invoice and expense audit workflow permissions.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:invoice:audit', 'Audit finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/audit', 'POST', 1375, 'active'),
('finance:invoice:unaudit', 'Unaudit finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/unaudit', 'POST', 1376, 'active'),
('finance:expense:audit', 'Audit finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/audit', 'POST', 1386, 'active'),
('finance:expense:unaudit', 'Unaudit finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/unaudit', 'POST', 1387, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'finance:invoice:audit',
    'finance:invoice:unaudit',
    'finance:expense:audit',
    'finance:expense:unaudit'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');


-- ============================================================================
-- Source: 048_finance_phase2_acceptance_fix.sql
-- ============================================================================
-- Finance phase 2 acceptance fixes:
-- 1. Warehouse roles must not see stock amount fields.
-- 2. Finance role can see cost/profit/stock amount data for reconciliation and reports.
-- 3. Invoice drafts created outside the API should default to draft.

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager', 'warehouse_admin', 'warehouse_staff')
  AND p.code IN ('inventory:stock:viewAmount', 'field:stock_amount:view');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:viewAmount',
    'field:stock_amount:view',
    'field:cost_price:view',
    'field:gross_profit:view',
    'field:gross_margin:view',
    'report:inventory:view'
)
WHERE r.code = 'finance';

ALTER TABLE finance_invoices ALTER COLUMN status SET DEFAULT 'draft';


-- ============================================================================
-- Source: 049_phase3_evidence_chain.sql
-- ============================================================================
-- Phase 3 evidence chain and data quality center.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('biz_relation:chain', 'Business relation chain', 'api', 'base', '/api/v1/biz-relations/chain', 'GET', 1302, 'active'),
('data_quality:list', 'Data quality center', 'api', 'report', '/api/v1/data-quality/center', 'GET', 1557, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('biz_relation:chain', 'data_quality:list');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 78, id, 'dataQualityCenter', 'data-quality', '/reports/data-quality/index', '', '数据一致性检查', 'Warning', 6
FROM menus
WHERE name = 'reports'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus WHERE id = 78;


-- ============================================================================
-- Source: 050_phase3_biz_relation_backfill.sql
-- ============================================================================
-- Backfill historical business relations for phase 3 evidence chain.

CREATE TABLE IF NOT EXISTS biz_relations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    source_type VARCHAR(64) NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    target_type VARCHAR(64) NOT NULL,
    target_id BIGINT UNSIGNED NOT NULL,
    target_no VARCHAR(64) NOT NULL DEFAULT '',
    relation_type VARCHAR(64) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_biz_rel_source (source_type, source_id),
    KEY idx_biz_rel_target (target_type, target_id),
    KEY idx_biz_rel_relation_type (relation_type)
);

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'quotation', q.id, q.quotation_no, 'sales_order', so.id, so.sales_order_no, 'convert', COALESCE(so.created_by, q.created_by, 0), COALESCE(so.created_at, q.updated_at, NOW())
FROM sales_orders so
JOIN quotations q ON q.id = so.source_quotation_id AND q.deleted_at IS NULL
WHERE so.deleted_at IS NULL AND so.source_quotation_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='quotation' AND br.source_id=q.id AND br.target_type='sales_order' AND br.target_id=so.id AND br.relation_type='convert');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'purchase_order', po.id, po.purchase_order_no, 'purchase', COALESCE(po.created_by, so.created_by, 0), COALESCE(po.created_at, NOW())
FROM purchase_orders po
JOIN sales_orders so ON so.id = po.source_sales_order_id AND so.deleted_at IS NULL
WHERE po.deleted_at IS NULL AND po.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='purchase_order' AND br.target_id=po.id AND br.relation_type='purchase');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'outbound_order', oo.id, oo.outbound_order_no, 'outbound', COALESCE(oo.created_by, so.created_by, 0), COALESCE(oo.created_at, NOW())
FROM inventory_outbound_orders oo
JOIN sales_orders so ON so.id = oo.source_sales_order_id AND so.deleted_at IS NULL
WHERE oo.deleted_at IS NULL AND oo.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='outbound_order' AND br.target_id=oo.id AND br.relation_type='outbound');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'receivable', r.id, r.receivable_no, 'receivable', COALESCE(r.created_by, so.created_by, 0), COALESCE(r.created_at, NOW())
FROM receivables r
JOIN sales_orders so ON so.id = r.sales_order_id AND so.deleted_at IS NULL
WHERE r.deleted_at IS NULL AND r.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='receivable' AND br.target_id=r.id AND br.relation_type='receivable');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'receipt', rp.id, rp.receipt_no, 'receipt', COALESCE(rp.created_by, so.created_by, 0), COALESCE(rp.created_at, NOW())
FROM receipts rp
JOIN sales_orders so ON so.id = rp.sales_order_id AND so.deleted_at IS NULL
WHERE rp.deleted_at IS NULL AND rp.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='receipt' AND br.target_id=rp.id AND br.relation_type='receipt');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, so.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN sales_orders so ON so.id = i.source_id AND i.source_type = 'sales_order' AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, r.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receivables r ON r.id = i.receivable_id AND r.deleted_at IS NULL
JOIN sales_orders so ON so.id = r.sales_order_id AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, rp.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receipts rp ON rp.id = i.receipt_id AND rp.deleted_at IS NULL
JOIN sales_orders so ON so.id = rp.sales_order_id AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.receipt_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'contract', c.id, c.contract_no, 'contract', COALESCE(c.created_by, so.created_by, 0), COALESCE(c.created_at, NOW())
FROM contracts c
JOIN sales_orders so ON so.id = c.sales_order_id AND so.deleted_at IS NULL
WHERE c.deleted_at IS NULL AND c.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='contract' AND br.target_id=c.id AND br.relation_type='contract');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'aftersales', a.id, a.ticket_no, 'aftersales', COALESCE(a.created_by, so.created_by, 0), COALESCE(a.created_at, NOW())
FROM aftersales a
JOIN sales_orders so ON so.id = a.sales_order_id AND so.deleted_at IS NULL
WHERE a.deleted_at IS NULL AND a.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='aftersales' AND br.target_id=a.id AND br.relation_type='aftersales');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'sales_return', sr.id, sr.return_no, 'return', COALESCE(sr.created_by, so.created_by, 0), COALESCE(sr.created_at, NOW())
FROM inventory_sales_return_orders sr
JOIN sales_orders so ON so.id = sr.source_sales_order_id AND so.deleted_at IS NULL
WHERE sr.deleted_at IS NULL AND sr.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='sales_return' AND br.target_id=sr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'outbound_order', oo.id, oo.outbound_order_no, 'sales_return', sr.id, sr.return_no, 'return', COALESCE(sr.created_by, oo.created_by, 0), COALESCE(sr.created_at, NOW())
FROM inventory_sales_return_orders sr
JOIN inventory_outbound_orders oo ON oo.id = sr.source_outbound_order_id AND oo.deleted_at IS NULL
WHERE sr.deleted_at IS NULL AND sr.source_outbound_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='outbound_order' AND br.source_id=oo.id AND br.target_type='sales_return' AND br.target_id=sr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'inbound_order', io.id, io.inbound_order_no, 'inbound', COALESCE(io.created_by, po.created_by, 0), COALESCE(io.created_at, NOW())
FROM inventory_inbound_orders io
JOIN purchase_orders po ON po.id = io.source_purchase_order_id AND po.deleted_at IS NULL
WHERE io.deleted_at IS NULL AND io.source_purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='inbound_order' AND br.target_id=io.id AND br.relation_type='inbound');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'payable', p.id, p.payable_no, 'payable', COALESCE(p.created_by, po.created_by, 0), COALESCE(p.created_at, NOW())
FROM payables p
JOIN purchase_orders po ON po.id = p.purchase_order_id AND po.deleted_at IS NULL
WHERE p.deleted_at IS NULL AND p.purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='payable' AND br.target_id=p.id AND br.relation_type='payable');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'payment', pm.id, pm.payment_no, 'payment', COALESCE(pm.created_by, po.created_by, 0), COALESCE(pm.created_at, NOW())
FROM payments pm
JOIN purchase_orders po ON po.id = pm.purchase_order_id AND po.deleted_at IS NULL
WHERE pm.deleted_at IS NULL AND pm.purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='payment' AND br.target_id=pm.id AND br.relation_type='payment');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, po.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN purchase_orders po ON po.id = i.source_id AND i.source_type = 'purchase_order' AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, p.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payables p ON p.id = i.payable_id AND p.deleted_at IS NULL
JOIN purchase_orders po ON po.id = p.purchase_order_id AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, pm.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payments pm ON pm.id = i.payment_id AND pm.deleted_at IS NULL
JOIN purchase_orders po ON po.id = pm.purchase_order_id AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.payment_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'purchase_return', pr.id, pr.return_no, 'return', COALESCE(pr.created_by, po.created_by, 0), COALESCE(pr.created_at, NOW())
FROM inventory_purchase_return_orders pr
JOIN purchase_orders po ON po.id = pr.source_purchase_order_id AND po.deleted_at IS NULL
WHERE pr.deleted_at IS NULL AND pr.source_purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='purchase_return' AND br.target_id=pr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'inbound_order', io.id, io.inbound_order_no, 'purchase_return', pr.id, pr.return_no, 'return', COALESCE(pr.created_by, io.created_by, 0), COALESCE(pr.created_at, NOW())
FROM inventory_purchase_return_orders pr
JOIN inventory_inbound_orders io ON io.id = pr.source_inbound_order_id AND io.deleted_at IS NULL
WHERE pr.deleted_at IS NULL AND pr.source_inbound_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='inbound_order' AND br.source_id=io.id AND br.target_type='purchase_return' AND br.target_id=pr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT i.source_type, i.source_id, i.source_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
WHERE i.deleted_at IS NULL AND i.source_type <> '' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type=i.source_type AND br.source_id=i.source_id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receivable', r.id, r.receivable_no, 'receipt', rp.id, rp.receipt_no, 'receipt', COALESCE(rp.created_by, r.created_by, 0), COALESCE(rp.created_at, NOW())
FROM receipts rp
JOIN receivables r ON r.id = rp.receivable_id AND r.deleted_at IS NULL
WHERE rp.deleted_at IS NULL AND rp.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receivable' AND br.source_id=r.id AND br.target_type='receipt' AND br.target_id=rp.id AND br.relation_type='receipt');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payable', p.id, p.payable_no, 'payment', pm.id, pm.payment_no, 'payment', COALESCE(pm.created_by, p.created_by, 0), COALESCE(pm.created_at, NOW())
FROM payments pm
JOIN payables p ON p.id = pm.payable_id AND p.deleted_at IS NULL
WHERE pm.deleted_at IS NULL AND pm.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payable' AND br.source_id=p.id AND br.target_type='payment' AND br.target_id=pm.id AND br.relation_type='payment');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receivable', r.id, r.receivable_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, r.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receivables r ON r.id = i.receivable_id AND r.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receivable' AND br.source_id=r.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payable', p.id, p.payable_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, p.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payables p ON p.id = i.payable_id AND p.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payable' AND br.source_id=p.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receipt', rp.id, rp.receipt_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, rp.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receipts rp ON rp.id = i.receipt_id AND rp.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.receipt_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receipt' AND br.source_id=rp.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payment', pm.id, pm.payment_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, pm.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payments pm ON pm.id = i.payment_id AND pm.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.payment_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payment' AND br.source_id=pm.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT e.biz_type, e.biz_id, e.biz_no, 'finance_expense', e.id, e.expense_no, 'expense', COALESCE(e.created_by, 0), COALESCE(e.created_at, NOW())
FROM finance_expense_orders e
WHERE e.deleted_at IS NULL AND e.biz_type <> '' AND e.biz_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type=e.biz_type AND br.source_id=e.biz_id AND br.target_type='finance_expense' AND br.target_id=e.id AND br.relation_type='expense');


-- ============================================================================
-- Source: 051_phase3_gross_profit_report.sql
-- ============================================================================
-- Phase 3 gross profit report drilldown, menu and permission.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('report:gross_profit:view', '毛利报表查看', 'api', 'report', '/api/v1/reports/gross-profit', 'GET', 1536, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('report:gross_profit:view', 'field:gross_profit:view', 'field:gross_margin:view');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('report:gross_profit:view', 'field:gross_profit:view', 'field:gross_margin:view')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 79, id, 'grossProfitReport', 'gross-profit', '/reports/gross-profit/index', '', '毛利报表', 'TrendCharts', 7
FROM menus
WHERE name = 'reports'
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus WHERE id = 79;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id = 79
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');


-- ============================================================================
-- Source: 052_phase3_relation_source_no_fix.sql
-- ============================================================================
-- Phase 3 relation source number completion for invoice-linked finance documents.

UPDATE biz_relations br
JOIN receivables r ON r.id = br.source_id
SET br.source_no = r.receivable_no
WHERE br.source_type = 'receivable'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN payables p ON p.id = br.source_id
SET br.source_no = p.payable_no
WHERE br.source_type = 'payable'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN receipts r ON r.id = br.source_id
SET br.source_no = r.receipt_no
WHERE br.source_type = 'receipt'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN payments p ON p.id = br.source_id
SET br.source_no = p.payment_no
WHERE br.source_type = 'payment'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');


-- ============================================================================
-- Source: 053_serial_number_records_schema_guard.sql
-- ============================================================================
-- Ensure SN status changes have a traceable business source even on databases
-- imported from older snapshots that did not include migration 044.

CREATE TABLE IF NOT EXISTS serial_number_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sn_id BIGINT UNSIGNED NOT NULL,
    sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL,
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sn_records_sn_id (sn_id),
    KEY idx_sn_records_sn_code (sn_code),
    KEY idx_sn_records_biz (biz_type, biz_id),
    KEY idx_sn_records_created_at (created_at)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE serial_number_records
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    MODIFY sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    MODIFY from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    MODIFY to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL;


-- ============================================================================
-- Source: 054_serial_number_records_collation_fix.sql
-- ============================================================================
-- Normalize SN record text columns on databases where the table was created
-- under MySQL 8's utf8mb4_0900_ai_ci default while older tables use
-- utf8mb4_unicode_ci.

ALTER TABLE serial_number_records
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    MODIFY sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    MODIFY from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    MODIFY to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL;


-- ============================================================================
-- Source: 055_crm_customer_operation.sql
-- ============================================================================
-- ERP 2.0 CRM customer operation foundation.
-- Adds CRM-compatible customer ownership fields, base CRM tables, permissions,
-- number rules, and menu entries without rebuilding the existing customer table.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_unique_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_unique_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD UNIQUE INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('customers', 'pool_status', 'VARCHAR(32) NOT NULL DEFAULT ''private'' COMMENT ''客户池状态 private/public/disabled''', 'status');
CALL add_column_if_missing('customers', 'last_follow_time', 'DATETIME NULL COMMENT ''最后跟进时间''', 'pool_status');
CALL add_column_if_missing('customers', 'last_follow_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''最后跟进人''', 'last_follow_time');
CALL add_column_if_missing('customers', 'next_follow_time', 'DATETIME NULL COMMENT ''下次跟进时间''', 'last_follow_user_id');
CALL add_column_if_missing('customers', 'source', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''客户来源''', 'next_follow_time');
CALL add_column_if_missing('customers', 'customer_type', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''客户类型''', 'source');

CALL add_index_if_missing('customers', 'idx_customers_pool_status', '`pool_status`');
CALL add_index_if_missing('customers', 'idx_customers_follow_time', '`last_follow_time`, `next_follow_time`');
CALL add_index_if_missing('customers', 'idx_customers_owner_pool', '`owner_user_id`, `owner_org_id`, `pool_status`');

UPDATE customers
SET pool_status = CASE
    WHEN status = 'disabled' THEN 'disabled'
    WHEN owner_user_id = 0 THEN 'public'
    ELSE 'private'
END
WHERE pool_status = ''
   OR pool_status IS NULL
   OR pool_status NOT IN ('private', 'public', 'disabled')
   OR (status = 'disabled' AND pool_status <> 'disabled')
   OR (owner_user_id = 0 AND status <> 'disabled' AND pool_status = 'private');

CREATE TABLE IF NOT EXISTS crm_contacts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    contact_name VARCHAR(64) NOT NULL,
    gender VARCHAR(16) NOT NULL DEFAULT '',
    position VARCHAR(64) NOT NULL DEFAULT '',
    department VARCHAR(64) NOT NULL DEFAULT '',
    phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    wechat VARCHAR(64) NOT NULL DEFAULT '',
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    decision_role VARCHAR(32) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_crm_contacts_customer (customer_id),
    KEY idx_crm_contacts_phone (phone),
    KEY idx_crm_contacts_primary (customer_id, is_primary),
    KEY idx_crm_contacts_decision_role (decision_role),
    KEY idx_crm_contacts_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE crm_contacts c
JOIN (
    SELECT customer_id, MAX(id) AS keep_id
    FROM crm_contacts
    WHERE is_primary = 1
      AND deleted_at IS NULL
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) d ON d.customer_id = c.customer_id
SET c.is_primary = 0,
    c.updated_at = CURRENT_TIMESTAMP
WHERE c.id <> d.keep_id
  AND c.is_primary = 1
  AND c.deleted_at IS NULL;

CALL add_column_if_missing(
    'crm_contacts',
    'primary_contact_customer_id',
    'BIGINT UNSIGNED GENERATED ALWAYS AS (CASE WHEN `is_primary` = 1 AND `deleted_at` IS NULL THEN `customer_id` ELSE NULL END) STORED COMMENT ''主联系人唯一约束辅助列''',
    'deleted_at'
);
CALL add_unique_index_if_missing('crm_contacts', 'uk_crm_contacts_primary_customer', '`primary_contact_customer_id`');

CREATE TABLE IF NOT EXISTS crm_follow_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    follow_type VARCHAR(32) NOT NULL DEFAULT '',
    follow_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    follow_content VARCHAR(2000) NOT NULL DEFAULT '',
    customer_feedback VARCHAR(1000) NOT NULL DEFAULT '',
    next_action VARCHAR(500) NOT NULL DEFAULT '',
    next_follow_time DATETIME NULL,
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    attachments JSON NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_crm_follow_customer_time (customer_id, follow_time),
    KEY idx_crm_follow_lead_time (lead_id, follow_time),
    KEY idx_crm_follow_opportunity_time (opportunity_id, follow_time),
    KEY idx_crm_follow_owner_time (owner_user_id, owner_org_id, follow_time),
    KEY idx_crm_follow_next_time (next_follow_time),
    KEY idx_crm_follow_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_customer_transfer_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    from_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    to_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    transfer_reason VARCHAR(500) NOT NULL DEFAULT '',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_crm_transfer_customer (customer_id, created_at),
    KEY idx_crm_transfer_from_user (from_user_id),
    KEY idx_crm_transfer_to_user (to_user_id),
    KEY idx_crm_transfer_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('crm_lead', 'CRM线索编号', 'XL', '20060102', 4, 'active', 'CRM 2.0 线索编号预置'),
('crm_opportunity', 'CRM商机编号', 'SJ', '20060102', 4, 'active', 'CRM 2.0 商机编号预置'),
('crm_task', 'CRM任务编号', 'RW', '20060102', 4, 'active', 'CRM 2.0 销售任务编号预置')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:contact:list', 'CRM联系人列表', 'api', 'crm', '/api/v1/crm/contacts', 'GET', 1601, 'active'),
('crm:contact:create', 'CRM联系人新增', 'api', 'crm', '/api/v1/crm/contacts', 'POST', 1602, 'active'),
('crm:contact:update', 'CRM联系人编辑', 'api', 'crm', '/api/v1/crm/contacts/:id', 'PUT', 1603, 'active'),
('crm:contact:delete', 'CRM联系人删除', 'api', 'crm', '/api/v1/crm/contacts/:id', 'DELETE', 1604, 'active'),
('crm:follow:list', 'CRM跟进记录列表', 'api', 'crm', '/api/v1/crm/follow-records', 'GET', 1611, 'active'),
('crm:follow:create', 'CRM跟进记录新增', 'api', 'crm', '/api/v1/crm/follow-records', 'POST', 1612, 'active'),
('crm:follow:update', 'CRM跟进记录编辑', 'api', 'crm', '/api/v1/crm/follow-records/:id', 'PUT', 1613, 'active'),
('crm:follow:delete', 'CRM跟进记录删除', 'api', 'crm', '/api/v1/crm/follow-records/:id', 'DELETE', 1614, 'active'),
('crm:customer:list', 'CRM客户列表', 'api', 'crm', '/api/v1/crm/customers', 'GET', 1620, 'active'),
('crm:customer:create', 'CRM客户新增', 'api', 'crm', '/api/v1/crm/customers', 'POST', 1621, 'active'),
('crm:customer:update', 'CRM客户编辑', 'api', 'crm', '/api/v1/crm/customers/:id', 'PUT', 1622, 'active'),
('crm:customer:delete', 'CRM客户删除', 'api', 'crm', '/api/v1/crm/customers/:id', 'DELETE', 1623, 'active'),
('crm:customer:enable', 'CRM客户启用', 'api', 'crm', '/api/v1/crm/customers/:id/enable', 'POST', 1624, 'active'),
('crm:customer:disable', 'CRM客户停用', 'api', 'crm', '/api/v1/crm/customers/:id/disable', 'POST', 1625, 'active'),
('crm:customer:export', 'CRM客户导出', 'api', 'crm', '/api/v1/crm/customers/export', 'GET', 1626, 'active'),
('crm:customer:claim', 'CRM公海客户领取', 'api', 'crm', '/api/v1/crm/customers/:id/claim', 'POST', 1631, 'active'),
('crm:customer:assign', 'CRM客户分配', 'api', 'crm', '/api/v1/crm/customers/:id/assign', 'POST', 1632, 'active'),
('crm:customer:transfer', 'CRM客户转移', 'api', 'crm', '/api/v1/crm/customers/:id/transfer', 'POST', 1633, 'active'),
('crm:customer:recycle', 'CRM客户回收公海', 'api', 'crm', '/api/v1/crm/customers/:id/recycle', 'POST', 1634, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:contact:list',
    'crm:contact:create',
    'crm:contact:update',
    'crm:contact:delete',
    'crm:follow:list',
    'crm:follow:create',
    'crm:follow:update',
    'crm:follow:delete',
    'crm:customer:list',
    'crm:customer:create',
    'crm:customer:update',
    'crm:customer:claim'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:assign',
    'crm:customer:transfer',
    'crm:customer:recycle',
    'crm:customer:delete',
    'crm:customer:enable',
    'crm:customer:disable',
    'crm:customer:export'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, crm_perm.id
FROM role_permissions rp
JOIN permissions old_perm ON old_perm.id = rp.permission_id
JOIN (
    SELECT 'customer:list' AS old_code, 'crm:customer:list' AS crm_code
    UNION ALL SELECT 'customer:create', 'crm:customer:create'
    UNION ALL SELECT 'customer:update', 'crm:customer:update'
    UNION ALL SELECT 'customer:delete', 'crm:customer:delete'
    UNION ALL SELECT 'customer:enable', 'crm:customer:enable'
    UNION ALL SELECT 'customer:disable', 'crm:customer:disable'
    UNION ALL SELECT 'customer:export', 'crm:customer:export'
    UNION ALL SELECT 'customer:transfer', 'crm:customer:transfer'
    UNION ALL SELECT 'customer:assignOwner', 'crm:customer:assign'
) perm_map ON perm_map.old_code = old_perm.code
JOIN permissions crm_perm ON crm_perm.code = perm_map.crm_code;

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code = 'sales'
  AND p.code IN ('crm:customer:assign', 'crm:customer:transfer', 'crm:customer:recycle', 'crm:customer:delete', 'crm:customer:enable', 'crm:customer:disable', 'crm:customer:export');

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
  );

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(80, 0, 'crm', '/crm', 'LAYOUT', '/crm/customers/my', 'CRM客户中心', 'User', 4)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(81, 80, 'crmCustomers', 'customers', '/crm/customers/index', '', '客户管理', 'UserFilled', 1),
(82, 81, 'crmMyCustomers', 'my', '/crm/customers/my/index', '', '我的客户', 'User', 2),
(83, 81, 'crmPublicCustomers', 'public', '/crm/customers/public/index', '', '公海客户', 'Connection', 3),
(84, 80, 'crmContacts', 'contacts', '/crm/contacts/index', '', '联系人管理', 'Avatar', 2),
(85, 80, 'crmFollowRecords', 'follow-records', '/crm/follow-records/index', '', '跟进管理', 'ChatLineRound', 3)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (80, 81, 82, 83, 84, 85)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

UPDATE menus
SET redirect = '/master-data/suppliers'
WHERE id = 4
  AND redirect = '/master-data/customers';

DELETE rm
FROM role_menus rm
WHERE rm.menu_id = 5;

DELETE FROM menus
WHERE id = 5;

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_unique_index_if_missing;


-- ============================================================================
-- Source: 056_deprecate_legacy_customer_permissions.sql
-- ============================================================================
-- Deprecate legacy customer management write permissions after CRM takeover.
-- Keep customer:list as a foundational read permission for shared selectors.

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
WHERE p.code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
);

UPDATE permissions
SET status = 'disabled'
WHERE code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
);


-- ============================================================================
-- Source: 057_crm_sales_process_phase2.sql
-- ============================================================================
-- ERP 2.0 CRM phase 2 sales process management.
-- Adds leads, opportunities, tasks, quotation source fields, permissions and menus.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('quotations', 'source_type', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''来源类型''', 'status');
CALL add_column_if_missing('quotations', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('quotations', 'opportunity_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''商机ID''', 'source_id');
CALL add_index_if_missing('quotations', 'idx_quotations_source', '`source_type`, `source_id`');
CALL add_index_if_missing('quotations', 'idx_quotations_opportunity', '`opportunity_id`');

CREATE TABLE IF NOT EXISTS crm_leads (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    lead_no VARCHAR(64) NOT NULL,
    lead_name VARCHAR(128) NOT NULL,
    company_name VARCHAR(128) NOT NULL DEFAULT '',
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    wechat VARCHAR(64) NOT NULL DEFAULT '',
    source VARCHAR(64) NOT NULL DEFAULT '',
    demand_desc VARCHAR(1000) NOT NULL DEFAULT '',
    expected_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'new',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    invalid_reason VARCHAR(500) NOT NULL DEFAULT '',
    lost_reason VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    last_follow_time DATETIME NULL,
    next_follow_time DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_leads_no (lead_no),
    KEY idx_crm_leads_status (status),
    KEY idx_crm_leads_owner (owner_user_id, owner_org_id),
    KEY idx_crm_leads_customer (customer_id),
    KEY idx_crm_leads_opportunity (opportunity_id),
    KEY idx_crm_leads_follow (last_follow_time, next_follow_time),
    KEY idx_crm_leads_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_opportunities (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    opportunity_no VARCHAR(64) NOT NULL,
    opportunity_name VARCHAR(128) NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    contact_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    stage VARCHAR(32) NOT NULL DEFAULT 'initial_contact',
    probability INT NOT NULL DEFAULT 10,
    expected_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    expected_close_date DATETIME NULL,
    demand_desc VARCHAR(1000) NOT NULL DEFAULT '',
    loss_reason VARCHAR(500) NOT NULL DEFAULT '',
    paused_reason VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    last_follow_time DATETIME NULL,
    next_follow_time DATETIME NULL,
    converted_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_opportunities_no (opportunity_no),
    KEY idx_crm_opportunities_customer (customer_id),
    KEY idx_crm_opportunities_contact (contact_id),
    KEY idx_crm_opportunities_project (project_id),
    KEY idx_crm_opportunities_quotation (quotation_id),
    KEY idx_crm_opportunities_lead (lead_id),
    KEY idx_crm_opportunities_stage (stage),
    KEY idx_crm_opportunities_owner (owner_user_id, owner_org_id),
    KEY idx_crm_opportunities_follow (last_follow_time, next_follow_time),
    KEY idx_crm_opportunities_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_tasks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    task_no VARCHAR(64) NOT NULL,
    title VARCHAR(128) NOT NULL,
    task_type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    due_time DATETIME NOT NULL,
    completed_at DATETIME NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_tasks_no (task_no),
    KEY idx_crm_tasks_type_status (task_type, status),
    KEY idx_crm_tasks_due (due_time),
    KEY idx_crm_tasks_owner (owner_user_id, owner_org_id),
    KEY idx_crm_tasks_customer (customer_id),
    KEY idx_crm_tasks_lead (lead_id),
    KEY idx_crm_tasks_opportunity (opportunity_id),
    KEY idx_crm_tasks_quotation (quotation_id),
    KEY idx_crm_tasks_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:lead:list', 'CRM线索列表', 'api', 'crm', '/api/v1/crm/leads', 'GET', 1641, 'active'),
('crm:lead:create', 'CRM线索新增', 'api', 'crm', '/api/v1/crm/leads', 'POST', 1642, 'active'),
('crm:lead:update', 'CRM线索编辑', 'api', 'crm', '/api/v1/crm/leads/:id', 'PUT', 1643, 'active'),
('crm:lead:delete', 'CRM线索删除', 'api', 'crm', '/api/v1/crm/leads/:id', 'DELETE', 1644, 'active'),
('crm:lead:assign', 'CRM线索分配', 'api', 'crm', '/api/v1/crm/leads/:id/assign', 'POST', 1645, 'active'),
('crm:lead:convert', 'CRM线索转客户', 'api', 'crm', '/api/v1/crm/leads/:id/convert', 'POST', 1646, 'active'),
('crm:opportunity:list', 'CRM商机列表', 'api', 'crm', '/api/v1/crm/opportunities', 'GET', 1651, 'active'),
('crm:opportunity:create', 'CRM商机新增', 'api', 'crm', '/api/v1/crm/opportunities', 'POST', 1652, 'active'),
('crm:opportunity:update', 'CRM商机编辑', 'api', 'crm', '/api/v1/crm/opportunities/:id', 'PUT', 1653, 'active'),
('crm:opportunity:delete', 'CRM商机删除', 'api', 'crm', '/api/v1/crm/opportunities/:id', 'DELETE', 1654, 'active'),
('crm:opportunity:quote', 'CRM商机转报价', 'api', 'crm', '/api/v1/crm/opportunities/:id/create-quotation', 'POST', 1655, 'active'),
('crm:task:list', 'CRM任务列表', 'api', 'crm', '/api/v1/crm/tasks', 'GET', 1661, 'active'),
('crm:task:create', 'CRM任务新增', 'api', 'crm', '/api/v1/crm/tasks', 'POST', 1662, 'active'),
('crm:task:update', 'CRM任务编辑', 'api', 'crm', '/api/v1/crm/tasks/:id', 'PUT', 1663, 'active'),
('crm:task:delete', 'CRM任务删除', 'api', 'crm', '/api/v1/crm/tasks/:id', 'DELETE', 1664, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:lead:list',
    'crm:lead:create',
    'crm:lead:update',
    'crm:lead:delete',
    'crm:lead:assign',
    'crm:lead:convert',
    'crm:opportunity:list',
    'crm:opportunity:create',
    'crm:opportunity:update',
    'crm:opportunity:delete',
    'crm:opportunity:quote',
    'crm:task:list',
    'crm:task:create',
    'crm:task:update',
    'crm:task:delete'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:lead:list',
    'crm:lead:create',
    'crm:lead:update',
    'crm:lead:convert',
    'crm:opportunity:list',
    'crm:opportunity:create',
    'crm:opportunity:update',
    'crm:opportunity:quote',
    'crm:task:list',
    'crm:task:create',
    'crm:task:update'
)
WHERE r.code = 'sales';

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(86, 80, 'crmLeads', 'leads', '/crm/leads/index', '', '线索管理', 'Tickets', 4),
(87, 80, 'crmOpportunities', 'opportunities', '/crm/opportunities/index', '', '商机管理', 'TrendCharts', 5),
(88, 80, 'crmTasks', 'tasks', '/crm/tasks/index', '', '销售任务', 'Calendar', 6)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (86, 87, 88)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 058_crm_dashboard_funnel.sql
-- ============================================================================
-- ERP 2.0 CRM phase 3 dashboard and sales funnel.
-- Adds CRM dashboard permission and menu without changing CRM business data.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:dashboard:view', 'CRM看板查看', 'api', 'crm', '/api/v1/crm/dashboard', 'GET', 1600, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'crm:dashboard:view'
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

UPDATE menus
SET redirect = '/crm/dashboard'
WHERE id = 80;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(89, 80, 'crmDashboard', 'dashboard', '/crm/dashboard/index', '', 'CRM看板', 'DataAnalysis', 0)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id = 89
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');


-- ============================================================================
-- Source: 059_dashboard_real_data_access_fix.sql
-- ============================================================================
-- ERP 2.0 dashboard real-data access fix.
-- Keeps the global workplace visible to common business roles and ensures
-- those roles can call the real dashboard summary APIs.
-- Also grants the read-only permissions used by the dashboard's metric mask;
-- sensitive finance/gross-profit fields are not broadened here.

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'dashboard'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'dashboard:view'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON (
    (r.code IN ('super_admin', 'admin', 'boss') AND p.code IN (
        'customer:list',
        'crm:customer:list',
        'supplier:list',
        'product:list',
        'sku:list',
        'project:list',
        'quotation:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list',
        'aftersales:ticket:list',
        'aftersales:list',
        'crm:dashboard:view',
        'crm:lead:list',
        'crm:opportunity:list',
        'crm:task:list'
    ))
    OR (r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director') AND p.code IN (
        'customer:list',
        'crm:customer:list',
        'project:list',
        'quotation:list',
        'sales:list',
        'inventory:stock:list',
        'product:list',
        'sku:list',
        'crm:dashboard:view',
        'crm:lead:list',
        'crm:opportunity:list',
        'crm:task:list'
    ))
    OR (r.code IN ('purchase', 'purchase_manager') AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'purchase:list',
        'inventory:stock:list'
    ))
    OR (r.code IN ('warehouse', 'warehouse_manager', 'warehouse_admin', 'warehouse_staff') AND p.code IN (
        'product:list',
        'sku:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list'
    ))
    OR (r.code = 'finance' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'report:sales:view',
        'report:purchase:view'
    ))
    OR (r.code = 'aftersales' AND p.code IN (
        'aftersales:ticket:list',
        'aftersales:list'
    ))
    OR (r.code = 'product_admin' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'inventory:stock:list'
    ))
    OR (r.code = 'auditor' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'project:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list',
        'aftersales:ticket:list',
        'aftersales:list',
        'report:sales:view',
        'report:purchase:view'
    ))
)
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
);

UPDATE customers c
JOIN users u ON u.id = c.owner_user_id
SET c.owner_org_id = u.organization_id
WHERE c.deleted_at IS NULL
  AND c.owner_user_id > 0
  AND (c.owner_org_id IS NULL OR c.owner_org_id = 0)
  AND u.organization_id > 0;

UPDATE receipts
SET status = 'confirmed'
WHERE deleted_at IS NULL
  AND status = 'active';

UPDATE payments
SET status = 'confirmed'
WHERE deleted_at IS NULL
  AND status = 'active';

UPDATE inventory_outbound_orders oo
JOIN users u ON u.id = oo.created_by
SET oo.owner_user_id = CASE WHEN oo.owner_user_id IS NULL OR oo.owner_user_id = 0 THEN oo.created_by ELSE oo.owner_user_id END,
    oo.owner_org_id = CASE WHEN oo.owner_org_id IS NULL OR oo.owner_org_id = 0 THEN u.organization_id ELSE oo.owner_org_id END
WHERE oo.deleted_at IS NULL
  AND oo.created_by > 0
  AND (oo.owner_user_id IS NULL OR oo.owner_user_id = 0 OR oo.owner_org_id IS NULL OR oo.owner_org_id = 0)
  AND u.organization_id > 0;


-- ============================================================================
-- Source: 060_crm_customer_pool_operation.sql
-- ============================================================================
-- ERP 2.0 CRM customer pool operation enhancement.
-- Rebuilds CRM customer pool menus, adds batch operation permissions,
-- customer pool timestamps, tags, and operation logs on top of customers.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('customers', 'returned_reason', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''退回公海原因''', 'customer_type');
CALL add_column_if_missing('customers', 'returned_at', 'DATETIME NULL COMMENT ''退回公海时间''', 'returned_reason');
CALL add_column_if_missing('customers', 'claimed_at', 'DATETIME NULL COMMENT ''领取时间''', 'returned_at');
CALL add_column_if_missing('customers', 'assigned_at', 'DATETIME NULL COMMENT ''分配时间''', 'claimed_at');

CALL add_index_if_missing('customers', 'idx_customers_pool_created', '`pool_status`, `created_at`');
CALL add_index_if_missing('customers', 'idx_customers_pool_owner', '`pool_status`, `owner_user_id`, `owner_org_id`');

CREATE TABLE IF NOT EXISTS crm_tags (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(100) NOT NULL COMMENT '标签名称',
    tag_color VARCHAR(30) NOT NULL DEFAULT '' COMMENT '标签颜色',
    tag_type VARCHAR(30) NOT NULL DEFAULT 'customer' COMMENT '标签类型 customer/lead/opportunity',
    status VARCHAR(30) NOT NULL DEFAULT 'enabled',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_tag_name_type (tag_name, tag_type),
    KEY idx_crm_tags_type_status (tag_type, status),
    KEY idx_crm_tags_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM标签表';

CREATE TABLE IF NOT EXISTS crm_customer_tags (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    tag_id BIGINT UNSIGNED NOT NULL COMMENT '标签ID',
    tag_name VARCHAR(100) NOT NULL COMMENT '标签名称快照',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_crm_customer_tag (customer_id, tag_id),
    KEY idx_crm_customer_tags_customer (customer_id),
    KEY idx_crm_customer_tags_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM客户标签关联表';

CREATE TABLE IF NOT EXISTS crm_customer_operation_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    customer_name VARCHAR(200) NOT NULL COMMENT '客户名称',
    action VARCHAR(50) NOT NULL COMMENT '操作类型 claim/assign/transfer/return_pool/delete/tag',
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '原负责人ID',
    from_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '原负责人名称',
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '新负责人ID',
    to_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '新负责人名称',
    reason VARCHAR(500) NOT NULL DEFAULT '' COMMENT '操作原因',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_crm_customer_op_customer (customer_id, created_at),
    KEY idx_crm_customer_op_action (action),
    KEY idx_crm_customer_op_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM客户操作记录表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:customer:batchClaim', 'CRM公海客户批量领取', 'api', 'crm', '/api/v1/crm/pool/batch-claim', 'POST', 1635, 'active'),
('crm:customer:batchAssign', 'CRM公海客户批量分配', 'api', 'crm', '/api/v1/crm/pool/batch-assign', 'POST', 1636, 'active'),
('crm:customer:batchTransfer', 'CRM我的客户批量转移', 'api', 'crm', '/api/v1/crm/my-customers/batch-transfer', 'POST', 1637, 'active'),
('crm:customer:batchRecycle', 'CRM我的客户批量退回公海', 'api', 'crm', '/api/v1/crm/my-customers/batch-return-pool', 'POST', 1638, 'active'),
('crm:customer:batchDelete', 'CRM公海客户批量删除', 'api', 'crm', '/api/v1/crm/pool/batch-delete', 'DELETE', 1639, 'active'),
('crm:customer:operationLog', 'CRM客户操作日志', 'api', 'crm', '/api/v1/crm/customer-operation-logs', 'GET', 1640, 'active'),
('crm:myCustomer:list', 'CRM我的客户列表', 'api', 'crm', '/api/v1/crm/my-customers', 'GET', 1641, 'active'),
('crm:myCustomer:view', 'CRM我的客户查看', 'api', 'crm', '/api/v1/crm/customers/:id', 'GET', 1642, 'active'),
('crm:myCustomer:update', 'CRM我的客户编辑', 'api', 'crm', '/api/v1/crm/customers/:id', 'PUT', 1643, 'active'),
('crm:myCustomer:batchTransfer', 'CRM我的客户批量转移', 'api', 'crm', '/api/v1/crm/my-customers/batch-transfer', 'POST', 1644, 'active'),
('crm:myCustomer:returnPool', 'CRM我的客户退回公海', 'api', 'crm', '/api/v1/crm/my-customers/batch-return-pool', 'POST', 1645, 'active'),
('crm:myCustomer:tag', 'CRM我的客户打标签', 'api', 'crm', '/api/v1/crm/my-customers/batch-tags', 'POST', 1646, 'active'),
('crm:myCustomer:export', 'CRM我的客户导出', 'api', 'crm', '/api/v1/crm/my-customers/export', 'GET', 1647, 'active'),
('crm:pool:list', 'CRM数据公海列表', 'api', 'crm', '/api/v1/crm/pool', 'GET', 1648, 'active'),
('crm:pool:view', 'CRM数据公海查看', 'api', 'crm', '/api/v1/crm/customers/:id', 'GET', 1649, 'active'),
('crm:pool:claim', 'CRM数据公海领取', 'api', 'crm', '/api/v1/crm/pool/batch-claim', 'POST', 1650, 'active'),
('crm:pool:assign', 'CRM数据公海分配', 'api', 'crm', '/api/v1/crm/pool/batch-assign', 'POST', 1651, 'active'),
('crm:pool:delete', 'CRM数据公海删除', 'api', 'crm', '/api/v1/crm/pool/batch-delete', 'DELETE', 1652, 'active'),
('crm:pool:tag', 'CRM数据公海打标签', 'api', 'crm', '/api/v1/crm/pool/batch-tags', 'POST', 1653, 'active'),
('crm:pool:export', 'CRM数据公海导出', 'api', 'crm', '/api/v1/crm/pool/export', 'GET', 1654, 'active'),
('crm:tag:list', 'CRM标签列表', 'api', 'crm', '/api/v1/crm/tags', 'GET', 1655, 'active'),
('crm:tag:create', 'CRM标签新增', 'api', 'crm', '/api/v1/crm/tags', 'POST', 1656, 'active'),
('crm:tag:update', 'CRM标签编辑', 'api', 'crm', '/api/v1/crm/tags/:id', 'PUT', 1657, 'active'),
('crm:tag:delete', 'CRM标签删除', 'api', 'crm', '/api/v1/crm/tags/:id', 'DELETE', 1658, 'active'),
('crm:tag:bind', 'CRM客户标签绑定', 'api', 'crm', '/api/v1/crm/tags/batch-bind-customers', 'POST', 1659, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

UPDATE menus
SET title = 'CRM中心',
    redirect = '/crm/dashboard'
WHERE id = 80 OR name = 'crm';

UPDATE menus
SET parent_id = 80,
    name = 'crmPublicCustomers',
    path = 'pool',
    component = '/crm/pool/index',
    title = '数据公海',
    icon = 'Connection',
    sort = 1
WHERE id = 83 OR name = 'crmPublicCustomers';

UPDATE menus
SET parent_id = 80,
    name = 'crmMyCustomers',
    path = 'my-customers',
    component = '/crm/my-customers/index',
    title = '我的客户',
    icon = 'User',
    sort = 2
WHERE id = 82 OR name = 'crmMyCustomers';

UPDATE menus SET sort = 0 WHERE id = 89 OR name = 'crmDashboard';
UPDATE menus SET sort = 3, title = '联系人管理' WHERE id = 84 OR name = 'crmContacts';
UPDATE menus SET sort = 4, title = '跟进记录' WHERE id = 85 OR name = 'crmFollowRecords';
UPDATE menus SET sort = 5, title = '商机管理' WHERE id = 87 OR name = 'crmOpportunities';
UPDATE menus SET sort = 6, title = '销售任务' WHERE id = 88 OR name = 'crmTasks';
UPDATE menus SET sort = 7, title = '线索管理' WHERE id = 86 OR name = 'crmLeads';

DELETE rm
FROM role_menus rm
JOIN menus m ON m.id = rm.menu_id
WHERE m.id = 81 OR m.name = 'crmCustomers';

DELETE FROM menus WHERE id = 81 OR name = 'crmCustomers';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN (
    'crm', 'crmDashboard', 'crmPublicCustomers', 'crmMyCustomers',
    'crmContacts', 'crmFollowRecords', 'crmOpportunities', 'crmTasks', 'crmLeads'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:batchClaim',
    'crm:myCustomer:list',
    'crm:myCustomer:view',
    'crm:myCustomer:update',
    'crm:myCustomer:batchTransfer',
    'crm:myCustomer:returnPool',
    'crm:myCustomer:tag',
    'crm:myCustomer:export',
    'crm:pool:list',
    'crm:pool:view',
    'crm:pool:claim',
    'crm:pool:tag',
    'crm:tag:list',
    'crm:tag:bind'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:batchAssign',
    'crm:customer:batchTransfer',
    'crm:customer:batchRecycle',
    'crm:customer:batchDelete',
    'crm:customer:operationLog',
    'crm:pool:assign',
    'crm:pool:delete',
    'crm:pool:export',
    'crm:tag:create',
    'crm:tag:update',
    'crm:tag:delete'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 061_aftersales_service_closure.sql
-- ============================================================================
-- ERP 2.0 aftersales service closure phase 1.
-- Enhances aftersales tickets with assignment, warranty snapshots,
-- processing records, operation logs, and phase-1 permissions.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('aftersales', 'title', 'VARCHAR(200) NOT NULL DEFAULT '''' COMMENT ''工单标题''', 'ticket_no');
CALL add_column_if_missing('aftersales', 'customer_name', 'VARCHAR(200) NOT NULL DEFAULT '''' COMMENT ''客户名称快照''', 'customer_id');
CALL add_column_if_missing('aftersales', 'contact_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''联系人ID''', 'customer_name');
CALL add_column_if_missing('aftersales', 'contact_name', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''联系人名称''', 'contact_id');
CALL add_column_if_missing('aftersales', 'contact_phone', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''联系电话''', 'contact_name');
CALL add_column_if_missing('aftersales', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号快照''', 'sales_order_id');
CALL add_column_if_missing('aftersales', 'contract_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同ID''', 'sales_order_no');
CALL add_column_if_missing('aftersales', 'contract_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''合同编号快照''', 'contract_id');
CALL add_column_if_missing('aftersales', 'sn_code', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''SN编码快照''', 'serial_number_id');
CALL add_column_if_missing('aftersales', 'ticket_type', 'VARCHAR(50) NOT NULL DEFAULT ''fault_repair'' COMMENT ''工单类型''', 'issue_desc');
CALL add_column_if_missing('aftersales', 'source', 'VARCHAR(50) NOT NULL DEFAULT ''manual'' COMMENT ''工单来源''', 'ticket_type');
CALL add_column_if_missing('aftersales', 'priority', 'VARCHAR(30) NOT NULL DEFAULT ''normal'' COMMENT ''优先级''', 'source');
CALL add_column_if_missing('aftersales', 'warranty_status', 'VARCHAR(30) NOT NULL DEFAULT ''unknown'' COMMENT ''质保状态''', 'priority');
CALL add_column_if_missing('aftersales', 'warranty_start_date', 'DATE NULL COMMENT ''质保开始日期''', 'warranty_status');
CALL add_column_if_missing('aftersales', 'warranty_end_date', 'DATE NULL COMMENT ''质保结束日期''', 'warranty_start_date');
CALL add_column_if_missing('aftersales', 'is_in_warranty', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否保内''', 'warranty_end_date');
CALL add_column_if_missing('aftersales', 'need_parts', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否需要备件''', 'is_in_warranty');
CALL add_column_if_missing('aftersales', 'need_rma', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否需要返厂''', 'need_parts');
CALL add_column_if_missing('aftersales', 'is_chargeable', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否收费''', 'need_rma');
CALL add_column_if_missing('aftersales', 'charge_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''收费金额''', 'is_chargeable');
CALL add_column_if_missing('aftersales', 'handler_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''处理人ID''', 'owner_org_id');
CALL add_column_if_missing('aftersales', 'handler_user_name', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''处理人名称''', 'handler_user_id');
CALL add_column_if_missing('aftersales', 'handler_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''处理部门ID''', 'handler_user_name');
CALL add_column_if_missing('aftersales', 'started_at', 'DATETIME NULL COMMENT ''开始处理时间''', 'processed_at');
CALL add_column_if_missing('aftersales', 'resolved_at', 'DATETIME NULL COMMENT ''解决时间''', 'started_at');
CALL add_column_if_missing('aftersales', 'cancelled_at', 'DATETIME NULL COMMENT ''取消时间''', 'closed_at');
CALL add_column_if_missing('aftersales', 'customer_confirm_status', 'VARCHAR(30) NOT NULL DEFAULT ''pending'' COMMENT ''客户确认状态''', 'cancelled_at');
CALL add_column_if_missing('aftersales', 'remark', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''备注''', 'customer_confirm_status');
CALL add_column_if_missing('sales_orders', 'completed_at', 'DATETIME NULL COMMENT ''完单时间''', 'confirmed_at');

CALL add_index_if_missing('aftersales', 'idx_aftersales_handler_status', '`handler_user_id`, `status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_priority_status', '`priority`, `status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_warranty_status', '`warranty_status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sn_code', '`sn_code`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_order_no', '`sales_order_no`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_sku', '`sales_order_id`, `sku_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_completed_at', '`completed_at`');
CALL add_index_if_missing('sales_order_items', 'idx_sales_order_items_order_sku', '`sales_order_id`, `sku_id`');

UPDATE aftersales
SET status = 'pending_assign'
WHERE status = 'draft';

UPDATE aftersales
SET status = 'closed'
WHERE status = 'completed';

CREATE TABLE IF NOT EXISTS aftersales_ticket_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL COMMENT '售后工单ID',
    ticket_no VARCHAR(64) NOT NULL COMMENT '售后工单号',
    record_type VARCHAR(50) NOT NULL DEFAULT 'handle' COMMENT '记录类型 handle/resolve/close/internal/customer',
    handle_method VARCHAR(50) NOT NULL DEFAULT '' COMMENT '处理方式',
    content VARCHAR(2000) NOT NULL DEFAULT '' COMMENT '处理内容',
    customer_feedback VARCHAR(1000) NOT NULL DEFAULT '' COMMENT '客户反馈',
    next_action VARCHAR(500) NOT NULL DEFAULT '' COMMENT '下一步动作',
    attachments JSON NULL COMMENT '附件',
    notify_customer TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否通知客户',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_aftersales_records_ticket (ticket_id, created_at),
    KEY idx_aftersales_records_operator (operator_id),
    KEY idx_aftersales_records_type (record_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后工单处理记录表';

CREATE TABLE IF NOT EXISTS aftersales_ticket_operation_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL COMMENT '售后工单ID',
    ticket_no VARCHAR(64) NOT NULL COMMENT '售后工单号',
    action VARCHAR(50) NOT NULL COMMENT '操作类型 create/update/assign/handle/resolve/close/cancel',
    status_from VARCHAR(50) NOT NULL DEFAULT '' COMMENT '原状态',
    status_to VARCHAR(50) NOT NULL DEFAULT '' COMMENT '新状态',
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '原处理人ID',
    from_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '原处理人名称',
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '新处理人ID',
    to_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '新处理人名称',
    reason VARCHAR(500) NOT NULL DEFAULT '' COMMENT '原因',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_aftersales_logs_ticket (ticket_id, created_at),
    KEY idx_aftersales_logs_action (action),
    KEY idx_aftersales_logs_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后工单操作日志表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('aftersales:ticket:list', '售后工单列表', 'api', 'aftersales', '/api/v1/aftersales/tickets', 'GET', 1401, 'active'),
('aftersales:ticket:create', '新增售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets', 'POST', 1402, 'active'),
('aftersales:ticket:update', '编辑售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id', 'PUT', 1403, 'active'),
('aftersales:ticket:view', '查看售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id', 'GET', 1404, 'active'),
('aftersales:ticket:assign', '分配售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/assign', 'POST', 1405, 'active'),
('aftersales:ticket:handle', '追加售后处理记录', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/records', 'POST', 1406, 'active'),
('aftersales:ticket:record', '查看售后处理记录', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/records', 'GET', 1407, 'active'),
('aftersales:ticket:resolve', '解决售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/resolve', 'POST', 1408, 'active'),
('aftersales:ticket:process', '处理售后工单(兼容)', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/process', 'POST', 1409, 'active'),
('aftersales:ticket:close', '关闭售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/close', 'POST', 1410, 'active'),
('aftersales:ticket:cancel', '取消售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/cancel', 'POST', 1411, 'active'),
('aftersales:ticket:export', '导出售后工单', 'button', 'aftersales', '', '', 1412, 'active'),
('aftersales:ticket:print', '打印售后工单', 'button', 'aftersales', '', '', 1413, 'active'),
('aftersales:ticket:attachment', '售后工单附件', 'button', 'aftersales', '', '', 1414, 'active'),
('aftersales:warranty:search', '质保查询', 'api', 'aftersales', '/api/v1/aftersales/warranty/search', 'GET', 1421, 'active'),
('aftersales:warranty:createTicket', '质保创建售后工单', 'api', 'aftersales', '/api/v1/aftersales/warranty/create-ticket', 'POST', 1422, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('aftersales_part_request', '售后备件申请编号', 'AP', '20060102', 4, 'active', '售后备件申请编号规则'),
('aftersales_rma', '售后返厂编号', 'AR', '20060102', 4, 'active', '售后返厂编号规则'),
('aftersales_visit', '售后回访编号', 'AV', '20060102', 4, 'active', '售后回访编号规则')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersales', 'aftersalesTickets', 'warrantySearch')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:list',
    'aftersales:ticket:view',
    'aftersales:ticket:create',
    'aftersales:ticket:update',
    'aftersales:ticket:record',
    'aftersales:warranty:search',
    'aftersales:warranty:createTicket'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:update',
    'aftersales:ticket:handle',
    'aftersales:ticket:resolve',
    'aftersales:ticket:process',
    'aftersales:ticket:close',
    'aftersales:ticket:assign',
    'aftersales:ticket:cancel',
    'aftersales:ticket:export',
    'aftersales:ticket:print',
    'aftersales:ticket:attachment'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
    'aftersales:ticket:assign',
    'aftersales:ticket:handle',
    'aftersales:ticket:resolve',
    'aftersales:ticket:process',
    'aftersales:ticket:close',
    'aftersales:ticket:cancel',
    'aftersales:ticket:attachment'
  );

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 062_sku_warranty_month.sql
-- ============================================================================
-- Add SKU-level default warranty month for aftersales warranty priority.

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('skus', 'warranty_month', 'INT NOT NULL DEFAULT 0 COMMENT ''SKU默认质保月数''', 'purchase_price');

DROP PROCEDURE IF EXISTS add_column_if_missing;


-- ============================================================================
-- Source: 063_aftersales_phase34.sql
-- ============================================================================
-- Aftersales phase 3 and 4: part requests, outbound integration, and RMA records.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.statistics
        WHERE table_schema = DATABASE() AND table_name = p_table_name AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('inventory_outbound_orders', 'source_biz_type', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''来源业务类型''', 'source_sales_order_id');
CALL add_column_if_missing('inventory_outbound_orders', 'source_biz_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源业务ID''', 'source_biz_type');
CALL add_column_if_missing('inventory_outbound_orders', 'source_biz_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''来源业务单号''', 'source_biz_id');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_inventory_outbound_orders_source_biz', '`source_biz_type`, `source_biz_id`');

CALL add_column_if_missing('aftersales', 'parts_cost_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''备件成本金额''', 'charge_amount');

CREATE TABLE IF NOT EXISTS aftersales_part_requests (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    request_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    warehouse_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    outbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_order_no VARCHAR(64) NOT NULL DEFAULT '',
    total_cost_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    submitted_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    submitted_at DATETIME NULL,
    audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    audited_at DATETIME NULL,
    outbound_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_at DATETIME NULL,
    cancelled_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    cancelled_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_part_requests_ticket (ticket_id),
    KEY idx_aftersales_part_requests_status (status),
    KEY idx_aftersales_part_requests_outbound (outbound_order_id),
    KEY idx_aftersales_part_requests_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后备件申请单';

CREATE TABLE IF NOT EXISTS aftersales_part_request_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    part_request_id BIGINT UNSIGNED NOT NULL,
    line_no INT NOT NULL DEFAULT 1,
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_code VARCHAR(64) NOT NULL DEFAULT '',
    sku_name VARCHAR(128) NOT NULL DEFAULT '',
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_aftersales_part_request_items_request (part_request_id),
    KEY idx_aftersales_part_request_items_sku (sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后备件申请明细';

CREATE TABLE IF NOT EXISTS aftersales_ticket_parts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    part_request_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    part_request_no VARCHAR(64) NOT NULL DEFAULT '',
    outbound_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    outbound_order_no VARCHAR(64) NOT NULL DEFAULT '',
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_code VARCHAR(64) NOT NULL DEFAULT '',
    sku_name VARCHAR(128) NOT NULL DEFAULT '',
    sku_spec VARCHAR(255) NOT NULL DEFAULT '',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_cost DECIMAL(18,4) NOT NULL DEFAULT 0,
    sn_codes JSON NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_aftersales_ticket_parts_ticket (ticket_id),
    KEY idx_aftersales_ticket_parts_request (part_request_id),
    KEY idx_aftersales_ticket_parts_outbound (outbound_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后工单备件记录';

CREATE TABLE IF NOT EXISTS aftersales_rma_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    rma_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sales_order_no VARCHAR(64) NOT NULL DEFAULT '',
    product_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sn_code VARCHAR(128) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    problem_desc VARCHAR(1000) NOT NULL DEFAULT '',
    process_note VARCHAR(1000) NOT NULL DEFAULT '',
    sent_at DATETIME NULL,
    returned_at DATETIME NULL,
    closed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_rma_orders_ticket (ticket_id),
    KEY idx_aftersales_rma_orders_status (status),
    KEY idx_aftersales_rma_orders_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后返厂单';

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'part-requests',
    child.component = '/aftersales/part-requests/index',
    child.redirect = '',
    child.title = '备件申请',
    child.icon = 'Box',
    child.sort = 3
WHERE child.name = 'aftersalesPartRequests';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesPartRequests', 'part-requests', '/aftersales/part-requests/index', '', '备件申请', 'Box', 3
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesPartRequests');

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'rma-orders',
    child.component = '/aftersales/rma-orders/index',
    child.redirect = '',
    child.title = '返厂维修',
    child.icon = 'Tools',
    child.sort = 4
WHERE child.name = 'aftersalesRMAOrders';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesRMAOrders', 'rma-orders', '/aftersales/rma-orders/index', '', '返厂维修', 'Tools', 4
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesRMAOrders');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersalesPartRequests', 'aftersalesRMAOrders')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 064_aftersales_phase56.sql
-- ============================================================================
-- Aftersales phase 5 and 6: visits, satisfaction, dashboard and reports.

CREATE TABLE IF NOT EXISTS aftersales_visits (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    visit_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    contact_name VARCHAR(100) NOT NULL DEFAULT '',
    contact_phone VARCHAR(100) NOT NULL DEFAULT '',
    handler_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    handler_user_name VARCHAR(100) NOT NULL DEFAULT '',
    visit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    visit_user_name VARCHAR(100) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    satisfaction VARCHAR(32) NOT NULL DEFAULT '',
    satisfaction_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    questionnaire JSON NULL,
    feedback VARCHAR(1000) NOT NULL DEFAULT '',
    improve_action VARCHAR(1000) NOT NULL DEFAULT '',
    next_action VARCHAR(64) NOT NULL DEFAULT '',
    new_ticket_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    new_ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    due_at DATETIME NULL,
    finished_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_visits_ticket (ticket_id),
    KEY idx_aftersales_visits_customer (customer_id),
    KEY idx_aftersales_visits_status (status),
    KEY idx_aftersales_visits_visit_user (visit_user_id),
    KEY idx_aftersales_visits_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后客户回访';

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark)
VALUES ('aftersales_visit', '售后回访编号', 'AV', '20060102', 4, 'active', '售后回访编号规则')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('aftersales:part:list', '备件申请列表', 'api', 'aftersales', '/api/v1/aftersales/part-requests', 'GET', 1431, 'active'),
('aftersales:part:apply', '提交备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests', 'POST', 1432, 'active'),
('aftersales:part:audit', '审核备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/audit', 'POST', 1433, 'active'),
('aftersales:part:outbound', '售后备件出库', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/outbound', 'POST', 1434, 'active'),
('aftersales:part:cancel', '取消备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/cancel', 'POST', 1435, 'active'),
('aftersales:rma:list', '返厂维修列表', 'api', 'aftersales', '/api/v1/aftersales/rma-orders', 'GET', 1441, 'active'),
('aftersales:rma:create', '创建返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders', 'POST', 1442, 'active'),
('aftersales:rma:update', '更新返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id', 'PUT', 1443, 'active'),
('aftersales:rma:send', '返厂寄出', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1444, 'active'),
('aftersales:rma:receive', '返厂收回', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1445, 'active'),
('aftersales:rma:close', '关闭返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1446, 'active'),
('aftersales:visit:list', '客户回访列表', 'api', 'aftersales', '/api/v1/aftersales/visits', 'GET', 1451, 'active'),
('aftersales:visit:create', '创建客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits', 'POST', 1452, 'active'),
('aftersales:visit:update', '更新客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits/:id', 'PUT', 1453, 'active'),
('aftersales:visit:finish', '完成客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits/:id/finish', 'POST', 1454, 'active'),
('aftersales:dashboard:view', '售后看板查看', 'api', 'aftersales', '/api/v1/aftersales/dashboard', 'GET', 1461, 'active'),
('aftersales:report:view', '售后报表查看', 'api', 'aftersales', '/api/v1/aftersales/reports', 'GET', 1471, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'visits',
    child.component = '/aftersales/visits/index',
    child.redirect = '',
    child.title = '客户回访',
    child.icon = 'ChatLineRound',
    child.sort = 5
WHERE child.name = 'aftersalesVisits';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesVisits', 'visits', '/aftersales/visits/index', '', '客户回访', 'ChatLineRound', 5
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesVisits');

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'dashboard',
    child.component = '/aftersales/dashboard/index',
    child.redirect = '',
    child.title = '售后看板',
    child.icon = 'DataAnalysis',
    child.sort = 6
WHERE child.name = 'aftersalesDashboard';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesDashboard', 'dashboard', '/aftersales/dashboard/index', '', '售后看板', 'DataAnalysis', 6
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesDashboard');

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'reports',
    child.component = '/aftersales/reports/index',
    child.redirect = '',
    child.title = '售后报表',
    child.icon = 'TrendCharts',
    child.sort = 7
WHERE child.name = 'aftersalesReports';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesReports', 'reports', '/aftersales/reports/index', '', '售后报表', 'TrendCharts', 7
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesReports');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersalesVisits')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('aftersales:ticket:record','aftersales:part:list','aftersales:part:apply','aftersales:part:cancel','aftersales:visit:list','aftersales:visit:create','aftersales:visit:update','aftersales:visit:finish')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersalesDashboard', 'aftersalesReports')
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:dashboard:view','aftersales:report:view',
    'aftersales:part:list','aftersales:part:apply','aftersales:part:audit',
    'aftersales:rma:list','aftersales:rma:create','aftersales:rma:update','aftersales:rma:send','aftersales:rma:receive','aftersales:rma:close'
)
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('aftersales:part:outbound')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'warehouse_manager', 'warehouse');


-- ============================================================================
-- Source: 065_frontend_route_404_compat.sql
-- ============================================================================
-- Fix legacy frontend menu component paths that can fall through to Vue 404.

UPDATE menus
SET component = '/crm/customers/index',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'customers'
  AND component = '/customer/index';


-- ============================================================================
-- Source: 066_dashboard_home_global_fix.sql
-- ============================================================================
-- Fix global home route fallback so refresh does not fall back to legacy workplace.

UPDATE menus
SET redirect = '/crm/dashboard',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'dashboard'
  AND (redirect = '' OR redirect IS NULL OR redirect IN ('/dashboard/workplace', '/dashboard/workplace/index'));

UPDATE menus
SET redirect = '/crm/dashboard',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'crm'
  AND (redirect = '' OR redirect IS NULL);


-- ============================================================================
-- Source: 067_restore_workplace_menu.sql
-- ============================================================================
-- Restore the global workplace menu while keeping CRM dashboard as an explicit CRM menu.
-- Migration 066 redirected the legacy dashboard menu to CRM to avoid refresh fallback;
-- this migration separates the two entries so "工作台" remains visible and usable.

UPDATE menus
SET component = '/dashboard/workplace/index',
    redirect = '',
    title = '工作台',
    icon = 'Odometer',
    sort = 1,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'dashboard';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'dashboard'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'finance',
    'auditor',
    'aftersales'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'dashboard:view'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'finance',
    'auditor',
    'aftersales'
);


-- ============================================================================
-- Source: 068_import_center_2.sql
-- ============================================================================
DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$
CREATE PROCEDURE add_column_if_missing(
    IN table_name_in VARCHAR(64),
    IN column_name_in VARCHAR(64),
    IN column_definition_in TEXT,
    IN after_column_in VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = table_name_in
          AND COLUMN_NAME = column_name_in
    ) THEN
        SET @sql = CONCAT(
            'ALTER TABLE `', table_name_in, '` ADD COLUMN `', column_name_in, '` ',
            column_definition_in,
            IF(after_column_in IS NULL OR after_column_in = '', '', CONCAT(' AFTER `', after_column_in, '`'))
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$
CREATE PROCEDURE add_index_if_missing(
    IN table_name_in VARCHAR(64),
    IN index_name_in VARCHAR(64),
    IN index_columns_in TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = table_name_in
          AND INDEX_NAME = index_name_in
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', table_name_in, '` ADD INDEX `', index_name_in, '` (', index_columns_in, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS import_templates (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    template_code VARCHAR(100) NOT NULL,
    template_name VARCHAR(100) NOT NULL,
    module_code VARCHAR(64) NOT NULL,
    template_version VARCHAR(32) NOT NULL,
    file_path VARCHAR(500) NOT NULL DEFAULT '',
    file_name VARCHAR(255) NOT NULL DEFAULT '',
    description VARCHAR(500) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_import_templates_code (template_code),
    KEY idx_import_templates_module (module_code),
    KEY idx_import_templates_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL add_column_if_missing('import_tasks', 'module_code', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'biz_type');
CALL add_column_if_missing('import_tasks', 'module_name', 'VARCHAR(100) NOT NULL DEFAULT ''''', 'module_code');
CALL add_column_if_missing('import_tasks', 'template_code', 'VARCHAR(100) NOT NULL DEFAULT ''''', 'module_name');
CALL add_column_if_missing('import_tasks', 'template_version', 'VARCHAR(32) NOT NULL DEFAULT ''''', 'template_code');
CALL add_column_if_missing('import_tasks', 'original_file_name', 'VARCHAR(255) NOT NULL DEFAULT ''''', 'file_name');
CALL add_column_if_missing('import_tasks', 'file_path', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'original_file_name');
CALL add_column_if_missing('import_tasks', 'import_strategy', 'VARCHAR(32) NOT NULL DEFAULT ''error_duplicate''', 'status');
CALL add_column_if_missing('import_tasks', 'skipped_rows', 'INT NOT NULL DEFAULT 0', 'failed_rows');
CALL add_column_if_missing('import_tasks', 'updated_rows', 'INT NOT NULL DEFAULT 0', 'skipped_rows');
CALL add_column_if_missing('import_tasks', 'error_file_path', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'updated_rows');
CALL add_column_if_missing('import_tasks', 'result_file_path', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'error_file_path');
CALL add_column_if_missing('import_tasks', 'progress', 'INT NOT NULL DEFAULT 0', 'result_file_path');
CALL add_column_if_missing('import_tasks', 'message', 'VARCHAR(1000) NOT NULL DEFAULT ''''', 'progress');
CALL add_column_if_missing('import_tasks', 'created_by_name', 'VARCHAR(100) NOT NULL DEFAULT ''''', 'created_by');
CALL add_column_if_missing('import_tasks', 'started_at', 'DATETIME NULL', 'confirmed_at');
CALL add_column_if_missing('import_tasks', 'finished_at', 'DATETIME NULL', 'started_at');
CALL add_column_if_missing('import_tasks', 'remark', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'finished_at');
CALL add_index_if_missing('import_tasks', 'idx_import_tasks_module_code', '`module_code`');
CALL add_index_if_missing('import_tasks', 'idx_import_tasks_template_code', '`template_code`');
CALL add_index_if_missing('import_tasks', 'idx_import_tasks_created_by', '`created_by`');

CALL add_column_if_missing('import_task_errors', 'raw_value', 'VARCHAR(1000) NOT NULL DEFAULT ''''', 'field_name');
CALL add_column_if_missing('import_task_errors', 'error_type', 'VARCHAR(64) NOT NULL DEFAULT ''business_rule_error''', 'raw_value');
CALL add_column_if_missing('import_task_errors', 'suggestion', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'message');
CALL add_index_if_missing('import_task_errors', 'idx_import_task_errors_type', '`error_type`');

INSERT INTO import_templates
(template_code, template_name, module_code, template_version, file_name, description, status)
VALUES
('customer_import_v1.0', '客户导入模板', 'crm', 'v1.0', '客户导入模板.xlsx', '客户导入到数据公海或我的客户', 'active'),
('contact_import_v1.0', '联系人导入模板', 'crm', 'v1.0', '联系人导入模板.xlsx', '联系人必须关联已存在客户', 'active'),
('lead_import_v1.0', '线索导入模板', 'crm', 'v1.0', '线索导入模板.xlsx', '负责人为空时导入为待分配线索', 'active'),
('supplier_import_v1.0', '供应商导入模板', 'supplier', 'v1.0', '供应商导入模板.xlsx', '供应商基础资料导入', 'active'),
('product_import_v1.0', '商品导入模板', 'product', 'v1.0', '商品导入模板.xlsx', '商品基础资料导入', 'active'),
('sku_import_v1.0', 'SKU导入模板', 'product', 'v1.0', 'SKU导入模板.xlsx', 'SKU导入只允许设置是否启用SN，不导入具体SN', 'active'),
('inventory_check_import_v1.0', '盘点结果导入模板', 'inventory', 'v1.0', '盘点结果导入模板.xlsx', '只更新盘点明细，不直接改库存', 'active')
ON DUPLICATE KEY UPDATE
template_name = VALUES(template_name),
module_code = VALUES(module_code),
template_version = VALUES(template_version),
file_name = VALUES(file_name),
description = VALUES(description),
status = VALUES(status),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('supplier', '供应商编号', 'GYS', '20060102', 4, 'active', '供应商导入自动编号')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('import:template:list', '导入模板查看', 'api', 'import', '/api/v1/import/templates/:bizType/info', 'GET', 1701, 'active'),
('import:template:download', '导入模板下载', 'api', 'import', '/api/v1/import/templates/:bizType', 'GET', 1702, 'active'),
('import:task:preview', '导入预览', 'api', 'import', '/api/v1/import/:bizType/preview', 'POST', 1703, 'active'),
('import:task:confirm', '确认导入', 'api', 'import', '/api/v1/import/:bizType/confirm', 'POST', 1704, 'active'),
('import:task:list', '导入任务列表', 'api', 'import', '/api/v1/import/tasks', 'GET', 1705, 'active'),
('import:task:view', '导入任务详情', 'api', 'import', '/api/v1/import/tasks/:id', 'GET', 1706, 'active'),
('import:task:errorDownload', '导入错误文件下载', 'api', 'import', '/api/v1/import/tasks/:id/error-file', 'GET', 1707, 'active'),
('crm:customer:import', '客户导入', 'button', 'crm', '', '', 1721, 'active'),
('crm:contact:import', '联系人导入', 'button', 'crm', '', '', 1722, 'active'),
('crm:lead:import', '线索导入', 'button', 'crm', '', '', 1723, 'active'),
('supplier:import', '供应商导入', 'button', 'supplier', '', '', 1724, 'active'),
('product:product:import', '商品导入', 'button', 'product', '', '', 1725, 'active'),
('product:sku:import', 'SKU导入', 'button', 'product', '', '', 1726, 'active'),
('inventory:check:import', '盘点结果导入', 'button', 'inventory', '', '', 1727, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

UPDATE permissions
SET status = 'inactive'
WHERE code IN ('serial:import', 'serial:importTemplate', 'serial:importConfirm', 'serial:importErrorDownload');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'import:template:list',
    'import:template:download',
    'import:task:preview',
    'import:task:confirm',
    'import:task:list',
    'import:task:view',
    'import:task:errorDownload',
    'crm:customer:import',
    'crm:contact:import',
    'crm:lead:import',
    'supplier:import',
    'product:product:import',
    'product:sku:import',
    'inventory:check:import'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'product_admin', 'warehouse_manager');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;


-- ============================================================================
-- Source: 069_product_sku_stock_import.sql
-- ============================================================================
INSERT INTO import_templates
(template_code, template_name, module_code, template_version, file_name, description, status)
VALUES
('product_sku_stock_import_v1.0', '商品SKU库存组合导入模板', 'inventory', 'v1.0', '商品SKU库存组合导入模板.xlsx', '商品、SKU和初始库存组合导入；库存通过手工入库单自动入库，不启用SN', 'active')
ON DUPLICATE KEY UPDATE
template_name = VALUES(template_name),
module_code = VALUES(module_code),
template_version = VALUES(template_version),
file_name = VALUES(file_name),
description = VALUES(description),
status = VALUES(status),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('inventory:productSkuStock:import', '商品SKU库存组合导入', 'button', 'inventory', '', '', 1728, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'inventory:productSkuStock:import'
WHERE r.code IN ('super_admin', 'admin', 'boss', 'product_admin', 'warehouse_manager', 'warehouse');


