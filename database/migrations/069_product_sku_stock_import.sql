INSERT INTO import_templates
(template_code, template_name, module_code, template_version, file_name, description, status)
VALUES
('product_sku_stock_import_v1.0', '商品SKU库存组合导入模板', 'inventory', 'v1.0', '商品SKU库存组合导入模板.xlsx', '商品、SKU和初始库存组合导入；库存通过手工入库单自动入库，不启用SN', 'active')
ON DUPLICATE KEY UPDATE
template_name = VALUES(template_name),
module_code = VALUES(module_code),
template_version = VALUES(template_version),
file_name = VALUES(file_name),
description = VALUES(description),
status = VALUES(status),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('inventory:productSkuStock:import', '商品SKU库存组合导入', 'button', 'inventory', '', '', 1728, 'active')
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
JOIN permissions p ON p.code = 'inventory:productSkuStock:import'
WHERE r.code IN ('super_admin', 'admin', 'boss', 'product_admin', 'warehouse_manager', 'warehouse');
