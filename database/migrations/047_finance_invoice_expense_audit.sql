-- Finance invoice and expense audit workflow permissions.

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:invoice:audit', 'Audit finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/audit', 'POST', 1375, 'active'),
('finance:invoice:unaudit', 'Unaudit finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/unaudit', 'POST', 1376, 'active'),
('finance:expense:audit', 'Audit finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/audit', 'POST', 1386, 'active'),
('finance:expense:unaudit', 'Unaudit finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/unaudit', 'POST', 1387, 'active')
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
    'finance:invoice:audit',
    'finance:invoice:unaudit',
    'finance:expense:audit',
    'finance:expense:unaudit'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');
