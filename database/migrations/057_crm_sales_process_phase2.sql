-- ERP 2.0 CRM phase 2 sales process management.
-- Adds leads, opportunities, tasks, quotation source fields, permissions and menus.

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

DELIMITER ;

CALL add_column_if_missing('quotations', 'source_type', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''来源类型''', 'status');
CALL add_column_if_missing('quotations', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('quotations', 'opportunity_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''商机ID''', 'source_id');
CALL add_index_if_missing('quotations', 'idx_quotations_source', '`source_type`, `source_id`');
CALL add_index_if_missing('quotations', 'idx_quotations_opportunity', '`opportunity_id`');

CREATE TABLE IF NOT EXISTS crm_leads (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    lead_no VARCHAR(64) NOT NULL,
    lead_name VARCHAR(128) NOT NULL,
    company_name VARCHAR(128) NOT NULL DEFAULT '',
    contact_name VARCHAR(64) NOT NULL DEFAULT '',
    contact_phone VARCHAR(64) NOT NULL DEFAULT '',
    email VARCHAR(128) NOT NULL DEFAULT '',
    wechat VARCHAR(64) NOT NULL DEFAULT '',
    source VARCHAR(64) NOT NULL DEFAULT '',
    demand_desc VARCHAR(1000) NOT NULL DEFAULT '',
    expected_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'new',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    invalid_reason VARCHAR(500) NOT NULL DEFAULT '',
    lost_reason VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    last_follow_time DATETIME NULL,
    next_follow_time DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_leads_no (lead_no),
    KEY idx_crm_leads_status (status),
    KEY idx_crm_leads_owner (owner_user_id, owner_org_id),
    KEY idx_crm_leads_customer (customer_id),
    KEY idx_crm_leads_opportunity (opportunity_id),
    KEY idx_crm_leads_follow (last_follow_time, next_follow_time),
    KEY idx_crm_leads_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_opportunities (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    opportunity_no VARCHAR(64) NOT NULL,
    opportunity_name VARCHAR(128) NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    contact_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    project_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    stage VARCHAR(32) NOT NULL DEFAULT 'initial_contact',
    probability INT NOT NULL DEFAULT 10,
    expected_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    expected_close_date DATETIME NULL,
    demand_desc VARCHAR(1000) NOT NULL DEFAULT '',
    loss_reason VARCHAR(500) NOT NULL DEFAULT '',
    paused_reason VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    last_follow_time DATETIME NULL,
    next_follow_time DATETIME NULL,
    converted_sales_order_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_opportunities_no (opportunity_no),
    KEY idx_crm_opportunities_customer (customer_id),
    KEY idx_crm_opportunities_contact (contact_id),
    KEY idx_crm_opportunities_project (project_id),
    KEY idx_crm_opportunities_quotation (quotation_id),
    KEY idx_crm_opportunities_lead (lead_id),
    KEY idx_crm_opportunities_stage (stage),
    KEY idx_crm_opportunities_owner (owner_user_id, owner_org_id),
    KEY idx_crm_opportunities_follow (last_follow_time, next_follow_time),
    KEY idx_crm_opportunities_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_tasks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    task_no VARCHAR(64) NOT NULL,
    title VARCHAR(128) NOT NULL,
    task_type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    due_time DATETIME NOT NULL,
    completed_at DATETIME NULL,
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    lead_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    opportunity_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    quotation_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    owner_org_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_crm_tasks_no (task_no),
    KEY idx_crm_tasks_type_status (task_type, status),
    KEY idx_crm_tasks_due (due_time),
    KEY idx_crm_tasks_owner (owner_user_id, owner_org_id),
    KEY idx_crm_tasks_customer (customer_id),
    KEY idx_crm_tasks_lead (lead_id),
    KEY idx_crm_tasks_opportunity (opportunity_id),
    KEY idx_crm_tasks_quotation (quotation_id),
    KEY idx_crm_tasks_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:lead:list', 'CRM线索列表', 'api', 'crm', '/api/v1/crm/leads', 'GET', 1641, 'active'),
('crm:lead:create', 'CRM线索新增', 'api', 'crm', '/api/v1/crm/leads', 'POST', 1642, 'active'),
('crm:lead:update', 'CRM线索编辑', 'api', 'crm', '/api/v1/crm/leads/:id', 'PUT', 1643, 'active'),
('crm:lead:delete', 'CRM线索删除', 'api', 'crm', '/api/v1/crm/leads/:id', 'DELETE', 1644, 'active'),
('crm:lead:assign', 'CRM线索分配', 'api', 'crm', '/api/v1/crm/leads/:id/assign', 'POST', 1645, 'active'),
('crm:lead:convert', 'CRM线索转客户', 'api', 'crm', '/api/v1/crm/leads/:id/convert', 'POST', 1646, 'active'),
('crm:opportunity:list', 'CRM商机列表', 'api', 'crm', '/api/v1/crm/opportunities', 'GET', 1651, 'active'),
('crm:opportunity:create', 'CRM商机新增', 'api', 'crm', '/api/v1/crm/opportunities', 'POST', 1652, 'active'),
('crm:opportunity:update', 'CRM商机编辑', 'api', 'crm', '/api/v1/crm/opportunities/:id', 'PUT', 1653, 'active'),
('crm:opportunity:delete', 'CRM商机删除', 'api', 'crm', '/api/v1/crm/opportunities/:id', 'DELETE', 1654, 'active'),
('crm:opportunity:quote', 'CRM商机转报价', 'api', 'crm', '/api/v1/crm/opportunities/:id/create-quotation', 'POST', 1655, 'active'),
('crm:task:list', 'CRM任务列表', 'api', 'crm', '/api/v1/crm/tasks', 'GET', 1661, 'active'),
('crm:task:create', 'CRM任务新增', 'api', 'crm', '/api/v1/crm/tasks', 'POST', 1662, 'active'),
('crm:task:update', 'CRM任务编辑', 'api', 'crm', '/api/v1/crm/tasks/:id', 'PUT', 1663, 'active'),
('crm:task:delete', 'CRM任务删除', 'api', 'crm', '/api/v1/crm/tasks/:id', 'DELETE', 1664, 'active')
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
    'crm:lead:list',
    'crm:lead:create',
    'crm:lead:update',
    'crm:lead:delete',
    'crm:lead:assign',
    'crm:lead:convert',
    'crm:opportunity:list',
    'crm:opportunity:create',
    'crm:opportunity:update',
    'crm:opportunity:delete',
    'crm:opportunity:quote',
    'crm:task:list',
    'crm:task:create',
    'crm:task:update',
    'crm:task:delete'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'crm:lead:list',
    'crm:lead:create',
    'crm:lead:update',
    'crm:lead:convert',
    'crm:opportunity:list',
    'crm:opportunity:create',
    'crm:opportunity:update',
    'crm:opportunity:quote',
    'crm:task:list',
    'crm:task:create',
    'crm:task:update'
)
WHERE r.code = 'sales';

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(86, 80, 'crmLeads', 'leads', '/crm/leads/index', '', '线索管理', 'Tickets', 4),
(87, 80, 'crmOpportunities', 'opportunities', '/crm/opportunities/index', '', '商机管理', 'TrendCharts', 5),
(88, 80, 'crmTasks', 'tasks', '/crm/tasks/index', '', '销售任务', 'Calendar', 6)
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
JOIN menus m ON m.id IN (86, 87, 88)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
