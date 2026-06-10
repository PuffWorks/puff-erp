-- Restore the global workplace menu while keeping CRM dashboard as an explicit CRM menu.
-- Migration 066 redirected the legacy dashboard menu to CRM to avoid refresh fallback;
-- this migration separates the two entries so "工作台" remains visible and usable.

UPDATE menus
SET component = '/dashboard/workplace/index',
    redirect = '',
    title = '工作台',
    icon = 'Odometer',
    sort = 1,
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'dashboard';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'dashboard'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'finance',
    'auditor',
    'aftersales'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'dashboard:view'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'finance',
    'auditor',
    'aftersales'
);
