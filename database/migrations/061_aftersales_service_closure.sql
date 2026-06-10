-- ERP 2.0 aftersales service closure phase 1.
-- Enhances aftersales tickets with assignment, warranty snapshots,
-- processing records, operation logs, and phase-1 permissions.

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

CALL add_column_if_missing('aftersales', 'title', 'VARCHAR(200) NOT NULL DEFAULT '''' COMMENT ''工单标题''', 'ticket_no');
CALL add_column_if_missing('aftersales', 'customer_name', 'VARCHAR(200) NOT NULL DEFAULT '''' COMMENT ''客户名称快照''', 'customer_id');
CALL add_column_if_missing('aftersales', 'contact_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''联系人ID''', 'customer_name');
CALL add_column_if_missing('aftersales', 'contact_name', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''联系人名称''', 'contact_id');
CALL add_column_if_missing('aftersales', 'contact_phone', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''联系电话''', 'contact_name');
CALL add_column_if_missing('aftersales', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号快照''', 'sales_order_id');
CALL add_column_if_missing('aftersales', 'contract_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同ID''', 'sales_order_no');
CALL add_column_if_missing('aftersales', 'contract_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''合同编号快照''', 'contract_id');
CALL add_column_if_missing('aftersales', 'sn_code', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''SN编码快照''', 'serial_number_id');
CALL add_column_if_missing('aftersales', 'ticket_type', 'VARCHAR(50) NOT NULL DEFAULT ''fault_repair'' COMMENT ''工单类型''', 'issue_desc');
CALL add_column_if_missing('aftersales', 'source', 'VARCHAR(50) NOT NULL DEFAULT ''manual'' COMMENT ''工单来源''', 'ticket_type');
CALL add_column_if_missing('aftersales', 'priority', 'VARCHAR(30) NOT NULL DEFAULT ''normal'' COMMENT ''优先级''', 'source');
CALL add_column_if_missing('aftersales', 'warranty_status', 'VARCHAR(30) NOT NULL DEFAULT ''unknown'' COMMENT ''质保状态''', 'priority');
CALL add_column_if_missing('aftersales', 'warranty_start_date', 'DATE NULL COMMENT ''质保开始日期''', 'warranty_status');
CALL add_column_if_missing('aftersales', 'warranty_end_date', 'DATE NULL COMMENT ''质保结束日期''', 'warranty_start_date');
CALL add_column_if_missing('aftersales', 'is_in_warranty', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否保内''', 'warranty_end_date');
CALL add_column_if_missing('aftersales', 'need_parts', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否需要备件''', 'is_in_warranty');
CALL add_column_if_missing('aftersales', 'need_rma', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否需要返厂''', 'need_parts');
CALL add_column_if_missing('aftersales', 'is_chargeable', 'TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''是否收费''', 'need_rma');
CALL add_column_if_missing('aftersales', 'charge_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''收费金额''', 'is_chargeable');
CALL add_column_if_missing('aftersales', 'handler_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''处理人ID''', 'owner_org_id');
CALL add_column_if_missing('aftersales', 'handler_user_name', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''处理人名称''', 'handler_user_id');
CALL add_column_if_missing('aftersales', 'handler_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''处理部门ID''', 'handler_user_name');
CALL add_column_if_missing('aftersales', 'started_at', 'DATETIME NULL COMMENT ''开始处理时间''', 'processed_at');
CALL add_column_if_missing('aftersales', 'resolved_at', 'DATETIME NULL COMMENT ''解决时间''', 'started_at');
CALL add_column_if_missing('aftersales', 'cancelled_at', 'DATETIME NULL COMMENT ''取消时间''', 'closed_at');
CALL add_column_if_missing('aftersales', 'customer_confirm_status', 'VARCHAR(30) NOT NULL DEFAULT ''pending'' COMMENT ''客户确认状态''', 'cancelled_at');
CALL add_column_if_missing('aftersales', 'remark', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''备注''', 'customer_confirm_status');
CALL add_column_if_missing('sales_orders', 'completed_at', 'DATETIME NULL COMMENT ''完单时间''', 'confirmed_at');

CALL add_index_if_missing('aftersales', 'idx_aftersales_handler_status', '`handler_user_id`, `status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_priority_status', '`priority`, `status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_warranty_status', '`warranty_status`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sn_code', '`sn_code`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_order_no', '`sales_order_no`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_sku', '`sales_order_id`, `sku_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_completed_at', '`completed_at`');
CALL add_index_if_missing('sales_order_items', 'idx_sales_order_items_order_sku', '`sales_order_id`, `sku_id`');

UPDATE aftersales
SET status = 'pending_assign'
WHERE status = 'draft';

UPDATE aftersales
SET status = 'closed'
WHERE status = 'completed';

CREATE TABLE IF NOT EXISTS aftersales_ticket_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL COMMENT '售后工单ID',
    ticket_no VARCHAR(64) NOT NULL COMMENT '售后工单号',
    record_type VARCHAR(50) NOT NULL DEFAULT 'handle' COMMENT '记录类型 handle/resolve/close/internal/customer',
    handle_method VARCHAR(50) NOT NULL DEFAULT '' COMMENT '处理方式',
    content VARCHAR(2000) NOT NULL DEFAULT '' COMMENT '处理内容',
    customer_feedback VARCHAR(1000) NOT NULL DEFAULT '' COMMENT '客户反馈',
    next_action VARCHAR(500) NOT NULL DEFAULT '' COMMENT '下一步动作',
    attachments JSON NULL COMMENT '附件',
    notify_customer TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否通知客户',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_aftersales_records_ticket (ticket_id, created_at),
    KEY idx_aftersales_records_operator (operator_id),
    KEY idx_aftersales_records_type (record_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后工单处理记录表';

CREATE TABLE IF NOT EXISTS aftersales_ticket_operation_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL COMMENT '售后工单ID',
    ticket_no VARCHAR(64) NOT NULL COMMENT '售后工单号',
    action VARCHAR(50) NOT NULL COMMENT '操作类型 create/update/assign/handle/resolve/close/cancel',
    status_from VARCHAR(50) NOT NULL DEFAULT '' COMMENT '原状态',
    status_to VARCHAR(50) NOT NULL DEFAULT '' COMMENT '新状态',
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '原处理人ID',
    from_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '原处理人名称',
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '新处理人ID',
    to_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '新处理人名称',
    reason VARCHAR(500) NOT NULL DEFAULT '' COMMENT '原因',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_aftersales_logs_ticket (ticket_id, created_at),
    KEY idx_aftersales_logs_action (action),
    KEY idx_aftersales_logs_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后工单操作日志表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('aftersales:ticket:list', '售后工单列表', 'api', 'aftersales', '/api/v1/aftersales/tickets', 'GET', 1401, 'active'),
('aftersales:ticket:create', '新增售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets', 'POST', 1402, 'active'),
('aftersales:ticket:update', '编辑售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id', 'PUT', 1403, 'active'),
('aftersales:ticket:view', '查看售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id', 'GET', 1404, 'active'),
('aftersales:ticket:assign', '分配售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/assign', 'POST', 1405, 'active'),
('aftersales:ticket:handle', '追加售后处理记录', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/records', 'POST', 1406, 'active'),
('aftersales:ticket:record', '查看售后处理记录', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/records', 'GET', 1407, 'active'),
('aftersales:ticket:resolve', '解决售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/resolve', 'POST', 1408, 'active'),
('aftersales:ticket:process', '处理售后工单(兼容)', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/process', 'POST', 1409, 'active'),
('aftersales:ticket:close', '关闭售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/close', 'POST', 1410, 'active'),
('aftersales:ticket:cancel', '取消售后工单', 'api', 'aftersales', '/api/v1/aftersales/tickets/:id/cancel', 'POST', 1411, 'active'),
('aftersales:ticket:export', '导出售后工单', 'button', 'aftersales', '', '', 1412, 'active'),
('aftersales:ticket:print', '打印售后工单', 'button', 'aftersales', '', '', 1413, 'active'),
('aftersales:ticket:attachment', '售后工单附件', 'button', 'aftersales', '', '', 1414, 'active'),
('aftersales:warranty:search', '质保查询', 'api', 'aftersales', '/api/v1/aftersales/warranty/search', 'GET', 1421, 'active'),
('aftersales:warranty:createTicket', '质保创建售后工单', 'api', 'aftersales', '/api/v1/aftersales/warranty/create-ticket', 'POST', 1422, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('aftersales_part_request', '售后备件申请编号', 'AP', '20060102', 4, 'active', '售后备件申请编号规则'),
('aftersales_rma', '售后返厂编号', 'AR', '20060102', 4, 'active', '售后返厂编号规则'),
('aftersales_visit', '售后回访编号', 'AV', '20060102', 4, 'active', '售后回访编号规则')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2)
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
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersales', 'aftersalesTickets', 'warrantySearch')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:list',
    'aftersales:ticket:view',
    'aftersales:ticket:create',
    'aftersales:ticket:update',
    'aftersales:ticket:record',
    'aftersales:warranty:search',
    'aftersales:warranty:createTicket'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:update',
    'aftersales:ticket:handle',
    'aftersales:ticket:resolve',
    'aftersales:ticket:process',
    'aftersales:ticket:close',
    'aftersales:ticket:assign',
    'aftersales:ticket:cancel',
    'aftersales:ticket:export',
    'aftersales:ticket:print',
    'aftersales:ticket:attachment'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
    'aftersales:ticket:assign',
    'aftersales:ticket:handle',
    'aftersales:ticket:resolve',
    'aftersales:ticket:process',
    'aftersales:ticket:close',
    'aftersales:ticket:cancel',
    'aftersales:ticket:attachment'
  );

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
