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
