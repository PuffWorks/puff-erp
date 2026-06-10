-- Aftersales phase 5 and 6: visits, satisfaction, dashboard and reports.

CREATE TABLE IF NOT EXISTS aftersales_visits (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    visit_no VARCHAR(64) NOT NULL UNIQUE,
    ticket_id BIGINT UNSIGNED NOT NULL,
    ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    customer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    customer_name VARCHAR(200) NOT NULL DEFAULT '',
    contact_name VARCHAR(100) NOT NULL DEFAULT '',
    contact_phone VARCHAR(100) NOT NULL DEFAULT '',
    handler_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    handler_user_name VARCHAR(100) NOT NULL DEFAULT '',
    visit_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    visit_user_name VARCHAR(100) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    satisfaction VARCHAR(32) NOT NULL DEFAULT '',
    satisfaction_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    questionnaire JSON NULL,
    feedback VARCHAR(1000) NOT NULL DEFAULT '',
    improve_action VARCHAR(1000) NOT NULL DEFAULT '',
    next_action VARCHAR(64) NOT NULL DEFAULT '',
    new_ticket_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    new_ticket_no VARCHAR(64) NOT NULL DEFAULT '',
    due_at DATETIME NULL,
    finished_at DATETIME NULL,
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_aftersales_visits_ticket (ticket_id),
    KEY idx_aftersales_visits_customer (customer_id),
    KEY idx_aftersales_visits_status (status),
    KEY idx_aftersales_visits_visit_user (visit_user_id),
    KEY idx_aftersales_visits_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='售后客户回访';

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark)
VALUES ('aftersales_visit', '售后回访编号', 'AV', '20060102', 4, 'active', '售后回访编号规则')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('aftersales:part:list', '备件申请列表', 'api', 'aftersales', '/api/v1/aftersales/part-requests', 'GET', 1431, 'active'),
('aftersales:part:apply', '提交备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests', 'POST', 1432, 'active'),
('aftersales:part:audit', '审核备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/audit', 'POST', 1433, 'active'),
('aftersales:part:outbound', '售后备件出库', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/outbound', 'POST', 1434, 'active'),
('aftersales:part:cancel', '取消备件申请', 'api', 'aftersales', '/api/v1/aftersales/part-requests/:id/cancel', 'POST', 1435, 'active'),
('aftersales:rma:list', '返厂维修列表', 'api', 'aftersales', '/api/v1/aftersales/rma-orders', 'GET', 1441, 'active'),
('aftersales:rma:create', '创建返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders', 'POST', 1442, 'active'),
('aftersales:rma:update', '更新返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id', 'PUT', 1443, 'active'),
('aftersales:rma:send', '返厂寄出', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1444, 'active'),
('aftersales:rma:receive', '返厂收回', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1445, 'active'),
('aftersales:rma:close', '关闭返厂维修', 'api', 'aftersales', '/api/v1/aftersales/rma-orders/:id/status', 'POST', 1446, 'active'),
('aftersales:visit:list', '客户回访列表', 'api', 'aftersales', '/api/v1/aftersales/visits', 'GET', 1451, 'active'),
('aftersales:visit:create', '创建客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits', 'POST', 1452, 'active'),
('aftersales:visit:update', '更新客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits/:id', 'PUT', 1453, 'active'),
('aftersales:visit:finish', '完成客户回访', 'api', 'aftersales', '/api/v1/aftersales/visits/:id/finish', 'POST', 1454, 'active'),
('aftersales:dashboard:view', '售后看板查看', 'api', 'aftersales', '/api/v1/aftersales/dashboard', 'GET', 1461, 'active'),
('aftersales:report:view', '售后报表查看', 'api', 'aftersales', '/api/v1/aftersales/reports', 'GET', 1471, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'visits',
    child.component = '/aftersales/visits/index',
    child.redirect = '',
    child.title = '客户回访',
    child.icon = 'ChatLineRound',
    child.sort = 5
WHERE child.name = 'aftersalesVisits';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesVisits', 'visits', '/aftersales/visits/index', '', '客户回访', 'ChatLineRound', 5
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesVisits');

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'dashboard',
    child.component = '/aftersales/dashboard/index',
    child.redirect = '',
    child.title = '售后看板',
    child.icon = 'DataAnalysis',
    child.sort = 6
WHERE child.name = 'aftersalesDashboard';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesDashboard', 'dashboard', '/aftersales/dashboard/index', '', '售后看板', 'DataAnalysis', 6
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesDashboard');

UPDATE menus child
JOIN menus parent ON parent.name = 'aftersales'
SET child.parent_id = parent.id,
    child.path = 'reports',
    child.component = '/aftersales/reports/index',
    child.redirect = '',
    child.title = '售后报表',
    child.icon = 'TrendCharts',
    child.sort = 7
WHERE child.name = 'aftersalesReports';

INSERT INTO menus (parent_id, name, path, component, redirect, title, icon, sort)
SELECT p.id, 'aftersalesReports', 'reports', '/aftersales/reports/index', '', '售后报表', 'TrendCharts', 7
FROM menus p
WHERE p.name = 'aftersales'
  AND NOT EXISTS (SELECT 1 FROM menus m WHERE m.name = 'aftersalesReports');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersalesVisits')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('aftersales:ticket:record','aftersales:part:list','aftersales:part:apply','aftersales:part:cancel','aftersales:visit:list','aftersales:visit:create','aftersales:visit:update','aftersales:visit:finish')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'aftersales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersalesDashboard', 'aftersalesReports')
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:dashboard:view','aftersales:report:view',
    'aftersales:part:list','aftersales:part:apply','aftersales:part:audit',
    'aftersales:rma:list','aftersales:rma:create','aftersales:rma:update','aftersales:rma:send','aftersales:rma:receive','aftersales:rma:close'
)
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('aftersales:part:outbound')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'warehouse_manager', 'warehouse');
