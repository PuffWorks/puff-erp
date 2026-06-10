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
