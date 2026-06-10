-- Phase 3 gross profit report drilldown, menu and permission.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('report:gross_profit:view', '毛利报表查看', 'api', 'report', '/api/v1/reports/gross-profit', 'GET', 1536, 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    permission_type = VALUES(permission_type),
    module = VALUES(module),
    path = VALUES(path),
    method = VALUES(method),
    sort = VALUES(sort),
    status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('report:gross_profit:view', 'field:gross_profit:view', 'field:gross_margin:view');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('report:gross_profit:view', 'field:gross_profit:view', 'field:gross_margin:view')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 79, id, 'grossProfitReport', 'gross-profit', '/reports/gross-profit/index', '', '毛利报表', 'TrendCharts', 7
FROM menus
WHERE name = 'reports'
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
SELECT 1, id FROM menus WHERE id = 79;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id = 79
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');
