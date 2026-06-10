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
