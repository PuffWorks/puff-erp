INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:writeoff:list', 'Finance writeoff list', 'api', 'finance', '/api/v1/finance/writeoffs', 'GET', 1346, 'active'),
('finance:writeoff:reverse', 'Finance writeoff reverse', 'api', 'finance', '/api/v1/finance/writeoffs/reverse', 'POST', 1347, 'active')
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
JOIN permissions p ON p.code IN ('finance:writeoff:list', 'finance:writeoff:reverse')
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');
