-- Cleanup and normalize menu route rows after route alignment.
-- Safe to run repeatedly. Removes duplicate system menu rows created by the
-- early 012 migration draft, then updates menu rows by stable menu name.

DELETE rm
FROM role_menus rm
JOIN menus m ON m.id = rm.menu_id
WHERE m.id IN (12, 13, 14, 15)
  AND m.name IN ('systemRoles', 'systemMenus', 'systemDicts', 'systemOperationLogs');

DELETE FROM menus
WHERE id IN (12, 13, 14, 15)
  AND name IN ('systemRoles', 'systemMenus', 'systemDicts', 'systemOperationLogs');

UPDATE menus
SET path = 'users',
    component = '/system/user/index',
    redirect = '',
    sort = 1,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemUsers';

UPDATE menus
SET path = 'roles',
    component = '/system/role/index',
    redirect = '',
    sort = 2,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemRoles';

UPDATE menus
SET path = 'menus',
    component = '/system/menu/index',
    redirect = '',
    sort = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemMenus';

UPDATE menus
SET path = 'organization',
    component = '/system/organization/index',
    redirect = '',
    sort = 4,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemOrganizations';

UPDATE menus
SET path = 'dicts',
    component = '/system/dictionary/index',
    redirect = '',
    sort = 5,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemDicts';

UPDATE menus
SET path = 'files',
    component = '/system/file/index',
    redirect = '',
    sort = 6,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemFiles';

UPDATE menus
SET path = 'login-record',
    component = '/system/login-record/index',
    redirect = '',
    sort = 7,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemLoginLogs';

UPDATE menus
SET path = 'operation-logs',
    component = '/system/operation-record/index',
    redirect = '',
    sort = 8,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemOperationLogs';

UPDATE menus
SET path = 'number-rules',
    component = '/system/number-rules/index',
    redirect = '',
    sort = 9,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'systemNumberRules';

UPDATE menus SET path = '/system', component = 'LAYOUT', redirect = '/system/users', updated_at = CURRENT_TIMESTAMP WHERE name = 'system';
UPDATE menus SET path = '/sales', component = 'LAYOUT', redirect = '/sales/quotations', updated_at = CURRENT_TIMESTAMP WHERE name = 'sales';
UPDATE menus SET path = 'quotations', component = '/quotation/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'quotations';
UPDATE menus SET path = 'orders', component = '/sales/index', redirect = '', sort = 2, updated_at = CURRENT_TIMESTAMP WHERE name = 'salesOrders';
UPDATE menus SET path = 'projects', component = '/project/index', redirect = '', sort = 3, updated_at = CURRENT_TIMESTAMP WHERE name = 'projects';
UPDATE menus SET path = '/purchase', component = 'LAYOUT', redirect = '/purchase/orders', updated_at = CURRENT_TIMESTAMP WHERE name = 'purchase';
UPDATE menus SET path = 'orders', component = '/purchase/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'purchaseOrders';
UPDATE menus SET path = '/inventory', component = 'LAYOUT', redirect = '/inventory/stocks', updated_at = CURRENT_TIMESTAMP WHERE name = 'inventory';
UPDATE menus SET path = 'stocks', component = '/inventory/stocks/index', redirect = '', sort = 1, updated_at = CURRENT_TIMESTAMP WHERE name = 'stocks';
UPDATE menus SET path = 'inbound-orders', component = '/inventory/inbound-orders/index', redirect = '', sort = 2, updated_at = CURRENT_TIMESTAMP WHERE name = 'inboundOrders';
UPDATE menus SET path = 'outbound-orders', component = '/inventory/outbound-orders/index', redirect = '', sort = 3, updated_at = CURRENT_TIMESTAMP WHERE name = 'outboundOrders';
UPDATE menus SET path = 'records', component = '/inventory/records/index', redirect = '', sort = 4, updated_at = CURRENT_TIMESTAMP WHERE name = 'inventoryRecords';
UPDATE menus SET path = 'serial-numbers', component = '/serial/index', redirect = '', sort = 5, updated_at = CURRENT_TIMESTAMP WHERE name = 'serialNumbers';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
CROSS JOIN menus m
WHERE r.code IN ('super_admin', 'admin');
