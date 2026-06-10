-- Phase 3 evidence chain and data quality center.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('biz_relation:chain', 'Business relation chain', 'api', 'base', '/api/v1/biz-relations/chain', 'GET', 1302, 'active'),
('data_quality:list', 'Data quality center', 'api', 'report', '/api/v1/data-quality/center', 'GET', 1557, 'active')
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
WHERE code IN ('biz_relation:chain', 'data_quality:list');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 78, id, 'dataQualityCenter', 'data-quality', '/reports/data-quality/index', '', '数据一致性检查', 'Warning', 6
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
SELECT 1, id FROM menus WHERE id = 78;
