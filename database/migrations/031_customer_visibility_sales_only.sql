-- Customer visibility is limited to the sales ownership chain.
-- Super admin can see all customers. Sales users see their own customers.
-- Sales leaders/managers/directors see their team or department scope.

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
    'customer:list',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code IN ('super_admin', 'sales', 'sales_leader', 'sales_manager', 'sales_director');

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code NOT IN ('super_admin', 'sales', 'sales_leader', 'sales_manager', 'sales_director')
  AND p.code IN (
      'customer:list',
      'customer:create',
      'customer:update',
      'customer:delete',
      'customer:transfer',
      'customer:assignOwner',
      'field:customer_contact:view',
      'field:customer_address:view'
  );
