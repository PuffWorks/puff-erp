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
