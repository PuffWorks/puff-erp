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
