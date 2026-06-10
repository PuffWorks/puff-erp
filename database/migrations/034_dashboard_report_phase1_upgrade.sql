INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (64, 44, 'financeReport', 'finance', '/reports/finance/index', '', '财务报表', 'Money', 4)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

UPDATE menus SET sort = 5 WHERE name = 'aftersalesReport';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('report:finance:view', '财务报表查看', 'api', 'report', '/api/v1/reports/finance', 'GET', 1531, 'active'),
('report:finance:export', '财务报表导出', 'button', 'report', '', '', 1532, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'financeReport'
WHERE r.code IN ('super_admin', 'boss', 'finance', 'auditor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'report:finance:view'
WHERE r.code IN ('super_admin', 'boss', 'finance', 'auditor');
