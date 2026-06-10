INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list',
    'field:stock_qty:view',
    'field:available_qty:view'
)
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData', 'products', 'skus', 'inventory', 'stocks')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager')
  AND p.code IN (
      'sku:viewCost',
      'inventory:stock:viewAmount',
      'field:cost_price:view',
      'field:purchase_price:view',
      'field:stock_amount:view',
      'field:gross_profit:view',
      'field:gross_margin:view',
      'purchase:viewPrice',
      'quotation:viewProfit',
      'sales:viewCost',
      'sales:viewProfit'
  );
