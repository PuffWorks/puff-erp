-- Finance phase 2 acceptance fixes:
-- 1. Warehouse roles must not see stock amount fields.
-- 2. Finance role can see cost/profit/stock amount data for reconciliation and reports.
-- 3. Invoice drafts created outside the API should default to draft.

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager', 'warehouse_admin', 'warehouse_staff')
  AND p.code IN ('inventory:stock:viewAmount', 'field:stock_amount:view');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:viewAmount',
    'field:stock_amount:view',
    'field:cost_price:view',
    'field:gross_profit:view',
    'field:gross_margin:view',
    'report:inventory:view'
)
WHERE r.code = 'finance';

ALTER TABLE finance_invoices ALTER COLUMN status SET DEFAULT 'draft';
