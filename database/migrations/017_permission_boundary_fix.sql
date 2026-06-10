INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('field:customer_contact:view', '查看客户联系方式', 'field', 'field', '', '', 2013, 'active'),
('field:customer_address:view', '查看客户地址', 'field', 'field', '', '', 2014, 'active')
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
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list',
    'field:stock_qty:view',
    'field:available_qty:view',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code IN ('sales', 'sales_manager');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('field:customer_contact:view', 'field:customer_address:view')
WHERE r.code IN ('super_admin', 'admin', 'boss');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_manager')
  AND p.code IN (
      'product:create', 'product:update', 'product:delete',
      'sku:create', 'sku:update', 'sku:delete',
      'warehouse:create', 'warehouse:update', 'warehouse:delete',
      'inventory:stock:viewAmount', 'field:stock_amount:view'
  );

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'sales_manager'
  AND p.code IN ('field:gross_profit:view', 'field:gross_margin:view');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager')
  AND p.code = 'sales:list';

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'finance'
  AND p.code = 'customer:list';
