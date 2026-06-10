-- ERP 2.0 CRM customer pool operation enhancement.
-- Rebuilds CRM customer pool menus, adds batch operation permissions,
-- customer pool timestamps, tags, and operation logs on top of customers.

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

CALL add_column_if_missing('customers', 'returned_reason', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''退回公海原因''', 'customer_type');
CALL add_column_if_missing('customers', 'returned_at', 'DATETIME NULL COMMENT ''退回公海时间''', 'returned_reason');
CALL add_column_if_missing('customers', 'claimed_at', 'DATETIME NULL COMMENT ''领取时间''', 'returned_at');
CALL add_column_if_missing('customers', 'assigned_at', 'DATETIME NULL COMMENT ''分配时间''', 'claimed_at');

CALL add_index_if_missing('customers', 'idx_customers_pool_created', '`pool_status`, `created_at`');
CALL add_index_if_missing('customers', 'idx_customers_pool_owner', '`pool_status`, `owner_user_id`, `owner_org_id`');

CREATE TABLE IF NOT EXISTS crm_tags (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(100) NOT NULL COMMENT '标签名称',
    tag_color VARCHAR(30) NOT NULL DEFAULT '' COMMENT '标签颜色',
    tag_type VARCHAR(30) NOT NULL DEFAULT 'customer' COMMENT '标签类型 customer/lead/opportunity',
    status VARCHAR(30) NOT NULL DEFAULT 'enabled',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_tag_name_type (tag_name, tag_type),
    KEY idx_crm_tags_type_status (tag_type, status),
    KEY idx_crm_tags_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM标签表';

CREATE TABLE IF NOT EXISTS crm_customer_tags (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    tag_id BIGINT UNSIGNED NOT NULL COMMENT '标签ID',
    tag_name VARCHAR(100) NOT NULL COMMENT '标签名称快照',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_crm_customer_tag (customer_id, tag_id),
    KEY idx_crm_customer_tags_customer (customer_id),
    KEY idx_crm_customer_tags_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM客户标签关联表';

CREATE TABLE IF NOT EXISTS crm_customer_operation_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    customer_name VARCHAR(200) NOT NULL COMMENT '客户名称',
    action VARCHAR(50) NOT NULL COMMENT '操作类型 claim/assign/transfer/return_pool/delete/tag',
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '原负责人ID',
    from_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '原负责人名称',
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '新负责人ID',
    to_user_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '新负责人名称',
    reason VARCHAR(500) NOT NULL DEFAULT '' COMMENT '操作原因',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    operator_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '操作人名称',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_crm_customer_op_customer (customer_id, created_at),
    KEY idx_crm_customer_op_action (action),
    KEY idx_crm_customer_op_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CRM客户操作记录表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:customer:batchClaim', 'CRM公海客户批量领取', 'api', 'crm', '/api/v1/crm/pool/batch-claim', 'POST', 1635, 'active'),
('crm:customer:batchAssign', 'CRM公海客户批量分配', 'api', 'crm', '/api/v1/crm/pool/batch-assign', 'POST', 1636, 'active'),
('crm:customer:batchTransfer', 'CRM我的客户批量转移', 'api', 'crm', '/api/v1/crm/my-customers/batch-transfer', 'POST', 1637, 'active'),
('crm:customer:batchRecycle', 'CRM我的客户批量退回公海', 'api', 'crm', '/api/v1/crm/my-customers/batch-return-pool', 'POST', 1638, 'active'),
('crm:customer:batchDelete', 'CRM公海客户批量删除', 'api', 'crm', '/api/v1/crm/pool/batch-delete', 'DELETE', 1639, 'active'),
('crm:customer:operationLog', 'CRM客户操作日志', 'api', 'crm', '/api/v1/crm/customer-operation-logs', 'GET', 1640, 'active'),
('crm:myCustomer:list', 'CRM我的客户列表', 'api', 'crm', '/api/v1/crm/my-customers', 'GET', 1641, 'active'),
('crm:myCustomer:view', 'CRM我的客户查看', 'api', 'crm', '/api/v1/crm/customers/:id', 'GET', 1642, 'active'),
('crm:myCustomer:update', 'CRM我的客户编辑', 'api', 'crm', '/api/v1/crm/customers/:id', 'PUT', 1643, 'active'),
('crm:myCustomer:batchTransfer', 'CRM我的客户批量转移', 'api', 'crm', '/api/v1/crm/my-customers/batch-transfer', 'POST', 1644, 'active'),
('crm:myCustomer:returnPool', 'CRM我的客户退回公海', 'api', 'crm', '/api/v1/crm/my-customers/batch-return-pool', 'POST', 1645, 'active'),
('crm:myCustomer:tag', 'CRM我的客户打标签', 'api', 'crm', '/api/v1/crm/my-customers/batch-tags', 'POST', 1646, 'active'),
('crm:myCustomer:export', 'CRM我的客户导出', 'api', 'crm', '/api/v1/crm/my-customers/export', 'GET', 1647, 'active'),
('crm:pool:list', 'CRM数据公海列表', 'api', 'crm', '/api/v1/crm/pool', 'GET', 1648, 'active'),
('crm:pool:view', 'CRM数据公海查看', 'api', 'crm', '/api/v1/crm/customers/:id', 'GET', 1649, 'active'),
('crm:pool:claim', 'CRM数据公海领取', 'api', 'crm', '/api/v1/crm/pool/batch-claim', 'POST', 1650, 'active'),
('crm:pool:assign', 'CRM数据公海分配', 'api', 'crm', '/api/v1/crm/pool/batch-assign', 'POST', 1651, 'active'),
('crm:pool:delete', 'CRM数据公海删除', 'api', 'crm', '/api/v1/crm/pool/batch-delete', 'DELETE', 1652, 'active'),
('crm:pool:tag', 'CRM数据公海打标签', 'api', 'crm', '/api/v1/crm/pool/batch-tags', 'POST', 1653, 'active'),
('crm:pool:export', 'CRM数据公海导出', 'api', 'crm', '/api/v1/crm/pool/export', 'GET', 1654, 'active'),
('crm:tag:list', 'CRM标签列表', 'api', 'crm', '/api/v1/crm/tags', 'GET', 1655, 'active'),
('crm:tag:create', 'CRM标签新增', 'api', 'crm', '/api/v1/crm/tags', 'POST', 1656, 'active'),
('crm:tag:update', 'CRM标签编辑', 'api', 'crm', '/api/v1/crm/tags/:id', 'PUT', 1657, 'active'),
('crm:tag:delete', 'CRM标签删除', 'api', 'crm', '/api/v1/crm/tags/:id', 'DELETE', 1658, 'active'),
('crm:tag:bind', 'CRM客户标签绑定', 'api', 'crm', '/api/v1/crm/tags/batch-bind-customers', 'POST', 1659, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

UPDATE menus
SET title = 'CRM中心',
    redirect = '/crm/dashboard'
WHERE id = 80 OR name = 'crm';

UPDATE menus
SET parent_id = 80,
    name = 'crmPublicCustomers',
    path = 'pool',
    component = '/crm/pool/index',
    title = '数据公海',
    icon = 'Connection',
    sort = 1
WHERE id = 83 OR name = 'crmPublicCustomers';

UPDATE menus
SET parent_id = 80,
    name = 'crmMyCustomers',
    path = 'my-customers',
    component = '/crm/my-customers/index',
    title = '我的客户',
    icon = 'User',
    sort = 2
WHERE id = 82 OR name = 'crmMyCustomers';

UPDATE menus SET sort = 0 WHERE id = 89 OR name = 'crmDashboard';
UPDATE menus SET sort = 3, title = '联系人管理' WHERE id = 84 OR name = 'crmContacts';
UPDATE menus SET sort = 4, title = '跟进记录' WHERE id = 85 OR name = 'crmFollowRecords';
UPDATE menus SET sort = 5, title = '商机管理' WHERE id = 87 OR name = 'crmOpportunities';
UPDATE menus SET sort = 6, title = '销售任务' WHERE id = 88 OR name = 'crmTasks';
UPDATE menus SET sort = 7, title = '线索管理' WHERE id = 86 OR name = 'crmLeads';

DELETE rm
FROM role_menus rm
JOIN menus m ON m.id = rm.menu_id
WHERE m.id = 81 OR m.name = 'crmCustomers';

DELETE FROM menus WHERE id = 81 OR name = 'crmCustomers';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN (
    'crm', 'crmDashboard', 'crmPublicCustomers', 'crmMyCustomers',
    'crmContacts', 'crmFollowRecords', 'crmOpportunities', 'crmTasks', 'crmLeads'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:batchClaim',
    'crm:myCustomer:list',
    'crm:myCustomer:view',
    'crm:myCustomer:update',
    'crm:myCustomer:batchTransfer',
    'crm:myCustomer:returnPool',
    'crm:myCustomer:tag',
    'crm:myCustomer:export',
    'crm:pool:list',
    'crm:pool:view',
    'crm:pool:claim',
    'crm:pool:tag',
    'crm:tag:list',
    'crm:tag:bind'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:batchAssign',
    'crm:customer:batchTransfer',
    'crm:customer:batchRecycle',
    'crm:customer:batchDelete',
    'crm:customer:operationLog',
    'crm:pool:assign',
    'crm:pool:delete',
    'crm:pool:export',
    'crm:tag:create',
    'crm:tag:update',
    'crm:tag:delete'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
