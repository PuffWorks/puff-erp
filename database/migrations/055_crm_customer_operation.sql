-- ERP 2.0 CRM customer operation foundation.
-- Adds CRM-compatible customer ownership fields, base CRM tables, permissions,
-- number rules, and menu entries without rebuilding the existing customer table.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_unique_index_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
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
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
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

CREATE PROCEDURE add_unique_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD UNIQUE INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('customers', 'pool_status', 'VARCHAR(32) NOT NULL DEFAULT ''private'' COMMENT ''客户池状态 private/public/disabled''', 'status');
CALL add_column_if_missing('customers', 'last_follow_time', 'DATETIME NULL COMMENT ''最后跟进时间''', 'pool_status');
CALL add_column_if_missing('customers', 'last_follow_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''最后跟进人''', 'last_follow_time');
CALL add_column_if_missing('customers', 'next_follow_time', 'DATETIME NULL COMMENT ''下次跟进时间''', 'last_follow_user_id');
CALL add_column_if_missing('customers', 'source', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''客户来源''', 'next_follow_time');
CALL add_column_if_missing('customers', 'customer_type', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''客户类型''', 'source');

CALL add_index_if_missing('customers', 'idx_customers_pool_status', '`pool_status`');
CALL add_index_if_missing('customers', 'idx_customers_follow_time', '`last_follow_time`, `next_follow_time`');
CALL add_index_if_missing('customers', 'idx_customers_owner_pool', '`owner_user_id`, `owner_org_id`, `pool_status`');

UPDATE customers
SET pool_status = CASE
    WHEN status = 'disabled' THEN 'disabled'
    WHEN owner_user_id = 0 THEN 'public'
    ELSE 'private'
END
WHERE pool_status = ''
   OR pool_status IS NULL
   OR pool_status NOT IN ('private', 'public', 'disabled')
   OR (status = 'disabled' AND pool_status <> 'disabled')
   OR (owner_user_id = 0 AND status <> 'disabled' AND pool_status = 'private');

CREATE TABLE IF NOT EXISTS crm_contacts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    contact_name VARCHAR(64) NOT NULL,
    gender VARCHAR(16) NOT NULL DEFAULT '',
    position VARCHAR(64) NOT NULL DEFAULT '',
    department VARCHAR(64) NOT NULL DEFAULT '',
    phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    wechat VARCHAR(64) NOT NULL DEFAULT '',
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    decision_role VARCHAR(32) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_crm_contacts_customer (customer_id),
    KEY idx_crm_contacts_phone (phone),
    KEY idx_crm_contacts_primary (customer_id, is_primary),
    KEY idx_crm_contacts_decision_role (decision_role),
    KEY idx_crm_contacts_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE crm_contacts c
JOIN (
    SELECT customer_id, MAX(id) AS keep_id
    FROM crm_contacts
    WHERE is_primary = 1
      AND deleted_at IS NULL
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) d ON d.customer_id = c.customer_id
SET c.is_primary = 0,
    c.updated_at = CURRENT_TIMESTAMP
WHERE c.id <> d.keep_id
  AND c.is_primary = 1
  AND c.deleted_at IS NULL;

CALL add_column_if_missing(
    'crm_contacts',
    'primary_contact_customer_id',
    'BIGINT UNSIGNED GENERATED ALWAYS AS (CASE WHEN `is_primary` = 1 AND `deleted_at` IS NULL THEN `customer_id` ELSE NULL END) STORED COMMENT ''主联系人唯一约束辅助列''',
    'deleted_at'
);
CALL add_unique_index_if_missing('crm_contacts', 'uk_crm_contacts_primary_customer', '`primary_contact_customer_id`');

CREATE TABLE IF NOT EXISTS crm_follow_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    follow_type VARCHAR(32) NOT NULL DEFAULT '',
    follow_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    follow_content VARCHAR(2000) NOT NULL DEFAULT '',
    customer_feedback VARCHAR(1000) NOT NULL DEFAULT '',
    next_action VARCHAR(500) NOT NULL DEFAULT '',
    next_follow_time DATETIME NULL,
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    attachments JSON NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_crm_follow_customer_time (customer_id, follow_time),
    KEY idx_crm_follow_lead_time (lead_id, follow_time),
    KEY idx_crm_follow_opportunity_time (opportunity_id, follow_time),
    KEY idx_crm_follow_owner_time (owner_user_id, owner_org_id, follow_time),
    KEY idx_crm_follow_next_time (next_follow_time),
    KEY idx_crm_follow_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_customer_transfer_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    from_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    to_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    from_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    to_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    transfer_reason VARCHAR(500) NOT NULL DEFAULT '',
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_crm_transfer_customer (customer_id, created_at),
    KEY idx_crm_transfer_from_user (from_user_id),
    KEY idx_crm_transfer_to_user (to_user_id),
    KEY idx_crm_transfer_operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('crm_lead', 'CRM线索编号', 'XL', '20060102', 4, 'active', 'CRM 2.0 线索编号预置'),
('crm_opportunity', 'CRM商机编号', 'SJ', '20060102', 4, 'active', 'CRM 2.0 商机编号预置'),
('crm_task', 'CRM任务编号', 'RW', '20060102', 4, 'active', 'CRM 2.0 销售任务编号预置')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:contact:list', 'CRM联系人列表', 'api', 'crm', '/api/v1/crm/contacts', 'GET', 1601, 'active'),
('crm:contact:create', 'CRM联系人新增', 'api', 'crm', '/api/v1/crm/contacts', 'POST', 1602, 'active'),
('crm:contact:update', 'CRM联系人编辑', 'api', 'crm', '/api/v1/crm/contacts/:id', 'PUT', 1603, 'active'),
('crm:contact:delete', 'CRM联系人删除', 'api', 'crm', '/api/v1/crm/contacts/:id', 'DELETE', 1604, 'active'),
('crm:follow:list', 'CRM跟进记录列表', 'api', 'crm', '/api/v1/crm/follow-records', 'GET', 1611, 'active'),
('crm:follow:create', 'CRM跟进记录新增', 'api', 'crm', '/api/v1/crm/follow-records', 'POST', 1612, 'active'),
('crm:follow:update', 'CRM跟进记录编辑', 'api', 'crm', '/api/v1/crm/follow-records/:id', 'PUT', 1613, 'active'),
('crm:follow:delete', 'CRM跟进记录删除', 'api', 'crm', '/api/v1/crm/follow-records/:id', 'DELETE', 1614, 'active'),
('crm:customer:list', 'CRM客户列表', 'api', 'crm', '/api/v1/crm/customers', 'GET', 1620, 'active'),
('crm:customer:create', 'CRM客户新增', 'api', 'crm', '/api/v1/crm/customers', 'POST', 1621, 'active'),
('crm:customer:update', 'CRM客户编辑', 'api', 'crm', '/api/v1/crm/customers/:id', 'PUT', 1622, 'active'),
('crm:customer:delete', 'CRM客户删除', 'api', 'crm', '/api/v1/crm/customers/:id', 'DELETE', 1623, 'active'),
('crm:customer:enable', 'CRM客户启用', 'api', 'crm', '/api/v1/crm/customers/:id/enable', 'POST', 1624, 'active'),
('crm:customer:disable', 'CRM客户停用', 'api', 'crm', '/api/v1/crm/customers/:id/disable', 'POST', 1625, 'active'),
('crm:customer:export', 'CRM客户导出', 'api', 'crm', '/api/v1/crm/customers/export', 'GET', 1626, 'active'),
('crm:customer:claim', 'CRM公海客户领取', 'api', 'crm', '/api/v1/crm/customers/:id/claim', 'POST', 1631, 'active'),
('crm:customer:assign', 'CRM客户分配', 'api', 'crm', '/api/v1/crm/customers/:id/assign', 'POST', 1632, 'active'),
('crm:customer:transfer', 'CRM客户转移', 'api', 'crm', '/api/v1/crm/customers/:id/transfer', 'POST', 1633, 'active'),
('crm:customer:recycle', 'CRM客户回收公海', 'api', 'crm', '/api/v1/crm/customers/:id/recycle', 'POST', 1634, 'active')
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
    'crm:contact:list',
    'crm:contact:create',
    'crm:contact:update',
    'crm:contact:delete',
    'crm:follow:list',
    'crm:follow:create',
    'crm:follow:update',
    'crm:follow:delete',
    'crm:customer:list',
    'crm:customer:create',
    'crm:customer:update',
    'crm:customer:claim'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:customer:assign',
    'crm:customer:transfer',
    'crm:customer:recycle',
    'crm:customer:delete',
    'crm:customer:enable',
    'crm:customer:disable',
    'crm:customer:export'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, crm_perm.id
FROM role_permissions rp
JOIN permissions old_perm ON old_perm.id = rp.permission_id
JOIN (
    SELECT 'customer:list' AS old_code, 'crm:customer:list' AS crm_code
    UNION ALL SELECT 'customer:create', 'crm:customer:create'
    UNION ALL SELECT 'customer:update', 'crm:customer:update'
    UNION ALL SELECT 'customer:delete', 'crm:customer:delete'
    UNION ALL SELECT 'customer:enable', 'crm:customer:enable'
    UNION ALL SELECT 'customer:disable', 'crm:customer:disable'
    UNION ALL SELECT 'customer:export', 'crm:customer:export'
    UNION ALL SELECT 'customer:transfer', 'crm:customer:transfer'
    UNION ALL SELECT 'customer:assignOwner', 'crm:customer:assign'
) perm_map ON perm_map.old_code = old_perm.code
JOIN permissions crm_perm ON crm_perm.code = perm_map.crm_code;

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code = 'sales'
  AND p.code IN ('crm:customer:assign', 'crm:customer:transfer', 'crm:customer:recycle', 'crm:customer:delete', 'crm:customer:enable', 'crm:customer:disable', 'crm:customer:export');

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
  );

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(80, 0, 'crm', '/crm', 'LAYOUT', '/crm/customers/my', 'CRM客户中心', 'User', 4)
ON DUPLICATE KEY UPDATE
    parent_id = VALUES(parent_id),
    name = VALUES(name),
    path = VALUES(path),
    component = VALUES(component),
    redirect = VALUES(redirect),
    title = VALUES(title),
    icon = VALUES(icon),
    sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(81, 80, 'crmCustomers', 'customers', '/crm/customers/index', '', '客户管理', 'UserFilled', 1),
(82, 81, 'crmMyCustomers', 'my', '/crm/customers/my/index', '', '我的客户', 'User', 2),
(83, 81, 'crmPublicCustomers', 'public', '/crm/customers/public/index', '', '公海客户', 'Connection', 3),
(84, 80, 'crmContacts', 'contacts', '/crm/contacts/index', '', '联系人管理', 'Avatar', 2),
(85, 80, 'crmFollowRecords', 'follow-records', '/crm/follow-records/index', '', '跟进管理', 'ChatLineRound', 3)
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
JOIN menus m ON m.id IN (80, 81, 82, 83, 84, 85)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

UPDATE menus
SET redirect = '/master-data/suppliers'
WHERE id = 4
  AND redirect = '/master-data/customers';

DELETE rm
FROM role_menus rm
WHERE rm.menu_id = 5;

DELETE FROM menus
WHERE id = 5;

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_unique_index_if_missing;
