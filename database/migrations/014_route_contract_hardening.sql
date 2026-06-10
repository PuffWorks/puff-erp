-- Harden frontend route contract after dynamic route normalization.
-- This migration is safe to run repeatedly. It keeps existing titles intact
-- while aligning path/component/redirect/icon/sort by stable menu name.

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(1, 0, 'dashboard', '/dashboard', 'LAYOUT', '', '工作台', 'Odometer', 1),
(2, 0, 'system', '/system', 'LAYOUT', '/system/users', '系统管理', 'Setting', 2),
(3, 2, 'systemUsers', 'users', '/system/user/index', '', '用户管理', 'User', 1),
(21, 2, 'systemRoles', 'roles', '/system/role/index', '', '角色管理', 'UserFilled', 2),
(22, 2, 'systemMenus', 'menus', '/system/menu/index', '', '菜单管理', 'Menu', 3),
(49, 2, 'systemOrganizations', 'organization', '/system/organization/index', '', '组织架构', 'OfficeBuilding', 4),
(23, 2, 'systemDicts', 'dicts', '/system/dictionary/index', '', '字典管理', 'Collection', 5),
(50, 2, 'systemFiles', 'files', '/system/file/index', '', '文件管理', 'FolderOpened', 6),
(51, 2, 'systemLoginLogs', 'login-record', '/system/login-record/index', '', '登录日志', 'Clock', 7),
(24, 2, 'systemOperationLogs', 'operation-logs', '/system/operation-record/index', '', '操作日志', 'Tickets', 8),
(25, 2, 'systemNumberRules', 'number-rules', '/system/number-rules/index', '', '编号规则', 'Operation', 9),
(4, 0, 'masterData', '/master-data', 'LAYOUT', '/master-data/customers', '基础资料', 'Collection', 3),
(5, 4, 'customers', 'customers', '/customer/index', '', '客户管理', 'UserFilled', 1),
(26, 4, 'suppliers', 'suppliers', '/supplier/index', '', '供应商管理', 'Van', 2),
(6, 4, 'products', 'products', '/product/index', '', '商品管理', 'Goods', 3),
(27, 4, 'skus', 'skus', '/sku/index', '', '商品SKU', 'GoodsFilled', 4),
(28, 4, 'warehouses', 'warehouses', '/warehouse/index', '', '仓库管理', 'House', 5),
(7, 0, 'sales', '/sales', 'LAYOUT', '/sales/quotations', '销售管理', 'Sell', 4),
(8, 7, 'quotations', 'quotations', '/quotation/index', '', '报价单', 'Document', 1),
(9, 7, 'salesOrders', 'orders', '/sales/index', '', '销售订单', 'Tickets', 2),
(29, 7, 'projects', 'projects', '/project/index', '', '项目管理', 'Folder', 3),
(10, 0, 'inventory', '/inventory', 'LAYOUT', '/inventory/stocks', '库存管理', 'Box', 5),
(11, 10, 'stocks', 'stocks', '/inventory/stocks/index', '', '当前库存', 'Box', 1),
(32, 10, 'inboundOrders', 'inbound-orders', '/inventory/inbound-orders/index', '', '入库单', 'Download', 2),
(33, 10, 'outboundOrders', 'outbound-orders', '/inventory/outbound-orders/index', '', '出库单', 'Upload', 3),
(34, 10, 'inventoryRecords', 'records', '/inventory/records/index', '', '库存流水', 'Tickets', 4),
(35, 10, 'serialNumbers', 'serial-numbers', '/serial/index', '', '序列号管理', 'Cpu', 5),
(17, 0, 'contract', '/contract', 'LAYOUT', '/contract/templates', '合同管理', 'DocumentChecked', 6),
(18, 17, 'contractTemplates', 'templates', '/contract/templates/index', '', '合同模板', 'Document', 1),
(19, 17, 'contractList', 'list', '/contract/list/index', '', '合同列表', '文件管理', 2),
(20, 17, 'contractFiles', 'files', '/contract/files/index', '', '合同附件', 'FolderOpened', 3),
(30, 0, 'purchase', '/purchase', 'LAYOUT', '/purchase/orders', '采购管理', 'ShoppingCart', 7),
(31, 30, 'purchaseOrders', 'orders', '/purchase/index', '', '采购订单', 'Tickets', 1),
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
(48, 44, 'aftersalesReport', 'aftersales', '/reports/aftersales/index', '', '售后报表', 'Service', 4),
(52, 0, 'messageCenter', '/messages', 'LAYOUT', '/messages/list', '消息中心', 'Message', 12),
(53, 52, 'myMessages', 'list', '/message/list/index', '', '我的消息', 'Message', 1),
(54, 52, 'myTodos', 'todos', '/message/todo/index', '', '我的待办', 'Bell', 2),
(55, 0, 'dataImport', '/import', 'LAYOUT', '/import/tasks', '数据导入', 'UploadFilled', 13),
(56, 55, 'importTasks', 'tasks', '/import/tasks/index', '', '导入任务', 'Upload', 1),
(57, 55, 'importLogs', 'logs', '/import/tasks/index', '', '导入日志', 'Tickets', 2)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
icon = VALUES(icon),
sort = VALUES(sort),
updated_at = CURRENT_TIMESTAMP;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
CROSS JOIN menus m
WHERE r.code IN ('super_admin', 'admin');
