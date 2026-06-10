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
