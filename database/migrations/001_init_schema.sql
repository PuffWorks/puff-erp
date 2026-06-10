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
