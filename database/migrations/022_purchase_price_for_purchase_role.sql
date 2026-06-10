INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('purchase:viewPrice', 'field:purchase_price:view')
WHERE r.code = 'purchase';
