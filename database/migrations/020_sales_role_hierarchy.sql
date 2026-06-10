INSERT INTO roles (code, name, data_scope, status, remark) VALUES
('sales_leader', 'Sales Team Leader', 'team', 'active', 'Can view and approve data in the current sales team'),
('sales_director', 'Sales Director', 'org', 'active', 'Can view sales department data and sales gross profit')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
data_scope = VALUES(data_scope),
status = VALUES(status),
remark = VALUES(remark);

UPDATE roles
SET name = 'Sales Manager',
    data_scope = 'org',
    remark = 'Can view and approve data in the sales department and child teams'
WHERE code = 'sales_manager';

UPDATE roles SET data_scope = 'team' WHERE code = 'sales_leader';
UPDATE roles SET data_scope = 'org' WHERE code = 'sales_director';
UPDATE roles SET data_scope = 'all' WHERE code IN ('super_admin', 'admin', 'boss');
UPDATE roles SET data_scope = 'self' WHERE code = 'sales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN (
    'dashboard',
    'customers',
    'projects',
    'quotations',
    'salesOrders',
    'contract',
    'contractList',
    'aftersales',
    'warrantySearch',
    'reports',
    'salesReport'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData', 'sales', 'contract', 'aftersales', 'reports')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('messageCenter', 'myMessages', 'myTodos')
WHERE r.code IN ('sales_leader', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'report:sales:view',
    'field:stock_qty:view',
    'field:available_qty:view'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'message:list',
    'message:todo:list',
    'message:read',
    'message:todo:done',
    'message:delete'
)
WHERE r.code IN ('sales_leader', 'sales_director');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list',
    'customer:create',
    'customer:update',
    'project:list',
    'project:create',
    'project:update',
    'project:follow',
    'quotation:list',
    'quotation:create',
    'quotation:update',
    'quotation:submit',
    'quotation:audit',
    'quotation:reject',
    'quotation:confirm',
    'quotation:convert',
    'quotation:copy',
    'quotation:export',
    'quotation:print',
    'sales:list',
    'sales:create',
    'sales:update',
    'sales:submit',
    'sales:audit',
    'sales:reject',
    'sales:confirm',
    'sales:checkStock',
    'sales:generatePurchase',
    'sales:export',
    'sales:print',
    'contract:list',
    'contract:create',
    'contract:upload',
    'contract:download',
    'finance:receivable:list',
    'aftersales:warranty:search',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code = 'sales_leader';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'quotation:audit',
    'quotation:reject',
    'sales:audit',
    'sales:reject',
    'report:sales:view',
    'field:customer_contact:view',
    'field:customer_address:view'
)
WHERE r.code = 'sales_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list',
    'customer:create',
    'customer:update',
    'customer:transfer',
    'customer:assignOwner',
    'project:list',
    'project:create',
    'project:update',
    'project:follow',
    'quotation:list',
    'quotation:create',
    'quotation:update',
    'quotation:submit',
    'quotation:audit',
    'quotation:reject',
    'quotation:confirm',
    'quotation:convert',
    'quotation:copy',
    'quotation:export',
    'quotation:print',
    'quotation:viewProfit',
    'sales:list',
    'sales:create',
    'sales:update',
    'sales:submit',
    'sales:audit',
    'sales:reject',
    'sales:confirm',
    'sales:checkStock',
    'sales:generatePurchase',
    'sales:export',
    'sales:print',
    'sales:viewProfit',
    'contract:list',
    'contract:create',
    'contract:upload',
    'contract:download',
    'finance:receivable:list',
    'report:sales:view',
    'aftersales:warranty:search',
    'field:gross_profit:view',
    'field:gross_margin:view',
    'field:customer_contact:view',
    'field:customer_address:view',
    'field:receivable_amount:view'
)
WHERE r.code = 'sales_director';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customer:transfer', 'customer:assignOwner')
WHERE r.code IN ('sales_manager', 'sales_director');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales_leader', 'sales_manager')
  AND p.code IN (
      'quotation:viewProfit',
      'sales:viewProfit',
      'field:gross_profit:view',
      'field:gross_margin:view',
      'field:cost_price:view',
      'field:purchase_price:view',
      'field:stock_amount:view',
      'inventory:stock:viewAmount'
  );
