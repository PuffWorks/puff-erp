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
