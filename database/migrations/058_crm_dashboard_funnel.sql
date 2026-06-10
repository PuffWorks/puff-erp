-- ERP 2.0 CRM phase 3 dashboard and sales funnel.
-- Adds CRM dashboard permission and menu without changing CRM business data.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('crm:dashboard:view', 'CRM看板查看', 'api', 'crm', '/api/v1/crm/dashboard', 'GET', 1600, 'active')
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
JOIN permissions p ON p.code = 'crm:dashboard:view'
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

UPDATE menus
SET redirect = '/crm/dashboard'
WHERE id = 80;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(89, 80, 'crmDashboard', 'dashboard', '/crm/dashboard/index', '', 'CRM看板', 'DataAnalysis', 0)
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
JOIN menus m ON m.id = 89
WHERE r.code IN ('super_admin', 'admin', 'boss', 'sales', 'sales_leader', 'sales_manager', 'sales_director');
