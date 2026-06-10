-- ERP 2.0 dashboard real-data access fix.
-- Keeps the global workplace visible to common business roles and ensures
-- those roles can call the real dashboard summary APIs.
-- Also grants the read-only permissions used by the dashboard's metric mask;
-- sensitive finance/gross-profit fields are not broadened here.

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
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
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
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON (
    (r.code IN ('super_admin', 'admin', 'boss') AND p.code IN (
        'customer:list',
        'crm:customer:list',
        'supplier:list',
        'product:list',
        'sku:list',
        'project:list',
        'quotation:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list',
        'aftersales:ticket:list',
        'aftersales:list',
        'crm:dashboard:view',
        'crm:lead:list',
        'crm:opportunity:list',
        'crm:task:list'
    ))
    OR (r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director') AND p.code IN (
        'customer:list',
        'crm:customer:list',
        'project:list',
        'quotation:list',
        'sales:list',
        'inventory:stock:list',
        'product:list',
        'sku:list',
        'crm:dashboard:view',
        'crm:lead:list',
        'crm:opportunity:list',
        'crm:task:list'
    ))
    OR (r.code IN ('purchase', 'purchase_manager') AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'purchase:list',
        'inventory:stock:list'
    ))
    OR (r.code IN ('warehouse', 'warehouse_manager', 'warehouse_admin', 'warehouse_staff') AND p.code IN (
        'product:list',
        'sku:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list'
    ))
    OR (r.code = 'finance' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'report:sales:view',
        'report:purchase:view'
    ))
    OR (r.code = 'aftersales' AND p.code IN (
        'aftersales:ticket:list',
        'aftersales:list'
    ))
    OR (r.code = 'product_admin' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'inventory:stock:list'
    ))
    OR (r.code = 'auditor' AND p.code IN (
        'supplier:list',
        'product:list',
        'sku:list',
        'project:list',
        'sales:list',
        'purchase:list',
        'inventory:stock:list',
        'inventory:inbound:list',
        'inventory:outbound:list',
        'aftersales:ticket:list',
        'aftersales:list',
        'report:sales:view',
        'report:purchase:view'
    ))
)
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
    'warehouse_manager',
    'warehouse_admin',
    'warehouse_staff',
    'finance',
    'aftersales',
    'product_admin',
    'auditor'
);

UPDATE customers c
JOIN users u ON u.id = c.owner_user_id
SET c.owner_org_id = u.organization_id
WHERE c.deleted_at IS NULL
  AND c.owner_user_id > 0
  AND (c.owner_org_id IS NULL OR c.owner_org_id = 0)
  AND u.organization_id > 0;

UPDATE receipts
SET status = 'confirmed'
WHERE deleted_at IS NULL
  AND status = 'active';

UPDATE payments
SET status = 'confirmed'
WHERE deleted_at IS NULL
  AND status = 'active';

UPDATE inventory_outbound_orders oo
JOIN users u ON u.id = oo.created_by
SET oo.owner_user_id = CASE WHEN oo.owner_user_id IS NULL OR oo.owner_user_id = 0 THEN oo.created_by ELSE oo.owner_user_id END,
    oo.owner_org_id = CASE WHEN oo.owner_org_id IS NULL OR oo.owner_org_id = 0 THEN u.organization_id ELSE oo.owner_org_id END
WHERE oo.deleted_at IS NULL
  AND oo.created_by > 0
  AND (oo.owner_user_id IS NULL OR oo.owner_user_id = 0 OR oo.owner_org_id IS NULL OR oo.owner_org_id = 0)
  AND u.organization_id > 0;
