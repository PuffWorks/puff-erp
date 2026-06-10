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
