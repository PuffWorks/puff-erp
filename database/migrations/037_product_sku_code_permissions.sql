INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('product:updateCode', '修改商品编码', 'button', 'product', '', '', 409, 'active'),
('sku:updateCode', '修改SKU编码', 'button', 'sku', '', '', 431, 'active')
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
JOIN permissions p ON p.code IN ('product:updateCode', 'sku:updateCode')
WHERE r.code IN ('super_admin', 'product_admin');
