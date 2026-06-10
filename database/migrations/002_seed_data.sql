INSERT INTO users (id, username, password_hash, display_name, status)
VALUES (1, 'admin', '$2a$10$yOcqosM6UTLC1GWy0lM/9.R742LAQkGzK26MSI3ICK/QRXhzZ3y36', '系统管理员', 'active')
ON DUPLICATE KEY UPDATE
password_hash = VALUES(password_hash),
display_name = VALUES(display_name),
status = VALUES(status);

INSERT INTO roles (id, code, name)
VALUES (1, 'super_admin', '超级管理员')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO user_roles (user_id, role_id)
VALUES (1, 1)
ON DUPLICATE KEY UPDATE
user_id = VALUES(user_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(1, 0, 'dashboard', '/dashboard', 'LAYOUT', '', '工作台', 'Odometer', 1),
(2, 0, 'system', '/system', 'LAYOUT', '/system/users', '系统管理', 'Setting', 2),
(3, 2, 'systemUsers', 'users', '/system/users/index', '', '用户管理', 'User', 1),
(4, 0, 'masterData', '/master-data', 'LAYOUT', '/master-data/customers', '基础资料', 'Collection', 3),
(5, 4, 'customers', 'customers', '/customer/index', '', '客户管理', 'UserFilled', 1),
(6, 4, 'products', 'products', '/product/index', '', '商品管理', 'Goods', 2),
(7, 0, 'sales', '/sales', 'LAYOUT', '/sales/quotations', '销售管理', 'Sell', 4),
(8, 7, 'quotations', 'quotations', '/quotation/index', '', '报价管理', 'Document', 1),
(9, 7, 'salesOrders', 'orders', '/sales/index', '', '销售订单', 'Tickets', 2),
(10, 0, 'inventory', '/inventory', 'LAYOUT', '/inventory/stocks', '库存管理', 'Box', 5),
(11, 10, 'stocks', 'stocks', '/inventory/stocks/index', '', '库存现存量', 'Box', 1)
ON DUPLICATE KEY UPDATE
title = VALUES(title),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1, 10),(1, 11)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(1, 'system:user:list', '查看用户'),
(2, 'system:role:list', '查看角色'),
(3, 'customer:list', '查看客户'),
(4, 'supplier:list', '查看供应商'),
(5, 'product:list', '查看商品'),
(6, 'warehouse:list', '查看仓库'),
(7, 'project:list', '查看项目'),
(8, 'quotation:list', '查看报价'),
(9, 'sales:list', '查看销售订单'),
(10, 'purchase:list', '查看采购订单'),
(11, 'inventory:list', '查看库存'),
(12, 'serial:list', '查看序列号'),
(13, 'aftersales:list', '查看售后'),
(14, 'finance:list', '查看财务'),
(15, 'dashboard:view', '查看工作台'),
(16, 'report:view', '查看报表')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),
(1, 9),(1, 10),(1, 11),(1, 12),(1, 13),(1, 14),(1, 15),(1, 16)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', 'Files', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3)
ON DUPLICATE KEY UPDATE
title = VALUES(title),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(17, 'contract:template:list', 'List contract templates'),
(18, 'contract:template:create', 'Create contract templates'),
(19, 'contract:template:update', 'Update contract templates'),
(20, 'contract:template:delete', 'Delete contract templates'),
(21, 'contract:template:download', 'Download contract templates'),
(22, 'contract:list', 'List contracts'),
(23, 'contract:create', 'Create contracts'),
(24, 'contract:update', 'Update contracts'),
(25, 'contract:delete', 'Delete contracts'),
(26, 'contract:upload', 'Upload contract files'),
(27, 'contract:download', 'Download contract files'),
(28, 'contract:sign', 'Sign contracts'),
(29, 'contract:cancel', 'Cancel contracts'),
(30, 'contract:complete', 'Complete contracts')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 17),(1, 18),(1, 19),(1, 20),(1, 21),(1, 22),(1, 23),
(1, 24),(1, 25),(1, 26),(1, 27),(1, 28),(1, 29),(1, 30)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(21, 2, 'systemRoles', 'roles', '/system/role/index', '', '角色管理', 'UserFilled', 2),
(22, 2, 'systemMenus', 'menus', '/system/menu/index', '', '菜单管理', 'Menu', 3),
(23, 2, 'systemDicts', 'dicts', '/system/dictionary/index', '', '数据字典', 'Files', 4),
(24, 2, 'systemOperationLogs', 'operation-logs', '/system/operation-record/index', '', '操作日志', 'Tickets', 5)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 21),(1, 22),(1, 23),(1, 24)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(31, 'system:menu:list', 'List system menus'),
(32, 'system:dict:list', 'List dictionaries'),
(33, 'system:operation-log:list', 'List operation logs'),
(34, 'system:number-rule:list', 'List number rules')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 31),(1, 32),(1, 33),(1, 34)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(25, 2, 'systemNumberRules', 'number-rules', '/system/number-rules/index', '', '编号规则', 'Operation', 6),
(26, 4, 'suppliers', 'suppliers', '/supplier/index', '', '供应商管理', 'Van', 2),
(27, 4, 'skus', 'skus', '/sku/index', '', 'SKU管理', 'GoodsFilled', 4),
(28, 4, 'warehouses', 'warehouses', '/warehouse/index', '', '仓库管理', 'House', 5),
(29, 7, 'projects', 'projects', '/project/index', '', '项目管理', 'Folder', 1),
(30, 0, 'purchase', '/purchase', 'LAYOUT', '/purchase/orders', '采购管理', 'ShoppingCart', 7),
(31, 30, 'purchaseOrders', 'orders', '/purchase/index', '', '采购订单', 'Tickets', 1),
(32, 10, 'inboundOrders', 'inbound-orders', '/inventory/inbound-orders/index', '', '入库单', 'Download', 2),
(33, 10, 'outboundOrders', 'outbound-orders', '/inventory/outbound-orders/index', '', '出库单', 'Upload', 3),
(34, 10, 'inventoryRecords', 'records', '/inventory/records/index', '', '库存流水', 'Tickets', 4),
(35, 10, 'serialNumbers', 'serial-numbers', '/serial/index', '', 'SN管理', 'Cpu', 5),
(36, 0, 'aftersales', '/aftersales', 'LAYOUT', '/aftersales/tickets', '售后管理', 'Service', 9),
(37, 36, 'aftersalesTickets', 'tickets', '/aftersales/tickets/index', '', '售后工单', 'Tickets', 1),
(38, 36, 'warrantySearch', 'warranty', '/aftersales/warranty/index', '', '质保查询', 'Search', 2),
(39, 0, 'finance', '/finance', 'LAYOUT', '/finance/receivables', '财务管理', 'Money', 10),
(40, 39, 'receivables', 'receivables', '/finance/receivables/index', '', '应收记录', 'Coin', 1),
(41, 39, 'payables', 'payables', '/finance/payables/index', '', '应付记录', 'Wallet', 2),
(42, 39, 'receipts', 'receipts', '/finance/receipts/index', '', '收款记录', 'DocumentChecked', 3),
(43, 39, 'payments', 'payments', '/finance/payments/index', '', '付款记录', 'CreditCard', 4),
(44, 0, 'reports', '/reports', 'LAYOUT', '/reports/sales', '报表中心', 'DataAnalysis', 11),
(45, 44, 'salesReport', 'sales', '/reports/sales/index', '', '销售报表', 'TrendCharts', 1),
(46, 44, 'purchaseReport', 'purchase', '/reports/purchase/index', '', '采购报表', 'ShoppingCart', 2),
(47, 44, 'inventoryReport', 'inventory', '/reports/inventory/index', '', '库存报表', 'Box', 3),
(48, 44, 'aftersalesReport', 'aftersales', '/reports/aftersales/index', '', '售后报表', 'Service', 4)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO role_menus (role_id, menu_id) VALUES
(1, 25),(1, 26),(1, 27),(1, 28),(1, 29),(1, 30),(1, 31),(1, 32),
(1, 33),(1, 34),(1, 35),(1, 36),(1, 37),(1, 38),(1, 39),(1, 40),
(1, 41),(1, 42),(1, 43),(1, 44),(1, 45),(1, 46),(1, 47),(1, 48)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

INSERT INTO permissions (id, code, name) VALUES
(35, 'system:role:create', 'Create roles'),
(36, 'system:role:update', 'Update roles'),
(37, 'system:role:delete', 'Delete roles'),
(38, 'system:menu:create', 'Create menus'),
(39, 'system:menu:update', 'Update menus'),
(40, 'system:menu:delete', 'Delete menus'),
(41, 'system:dict:create', 'Create dictionaries'),
(42, 'system:dict:update', 'Update dictionaries'),
(43, 'system:dict:delete', 'Delete dictionaries'),
(44, 'system:number-rule:create', 'Create number rules'),
(45, 'system:number-rule:update', 'Update number rules'),
(46, 'system:number-rule:delete', 'Delete number rules'),
(47, 'system:permission:list', 'List permissions'),
(48, 'finance:receipt:list', 'List receipts'),
(49, 'finance:payment:list', 'List payments'),
(50, 'report:sales', 'View sales report'),
(51, 'report:purchase', 'View purchase report'),
(52, 'report:inventory', 'View inventory report'),
(53, 'report:aftersales', 'View aftersales report')
ON DUPLICATE KEY UPDATE
name = VALUES(name);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 35),(1, 36),(1, 37),(1, 38),(1, 39),(1, 40),(1, 41),(1, 42),
(1, 43),(1, 44),(1, 45),(1, 46),(1, 47),(1, 48),(1, 49),(1, 50),
(1, 51),(1, 52),(1, 53)
ON DUPLICATE KEY UPDATE
role_id = VALUES(role_id);

