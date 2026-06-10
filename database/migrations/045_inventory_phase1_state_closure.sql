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
