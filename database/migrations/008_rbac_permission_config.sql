DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND column_name = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            IF(p_after_column = '', '', CONCAT(' AFTER `', p_after_column, '`'))
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('roles', 'data_scope', 'VARCHAR(30) NOT NULL DEFAULT ''self'' COMMENT ''数据范围 all/team/self/custom''', 'name');
CALL add_column_if_missing('roles', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active'' COMMENT ''状态 active/disabled''', 'data_scope');
CALL add_column_if_missing('roles', 'remark', 'VARCHAR(500) NOT NULL DEFAULT '''' COMMENT ''备注''', 'status');

CALL add_column_if_missing('permissions', 'parent_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''父级权限ID''', 'id');
CALL add_column_if_missing('permissions', 'permission_type', 'VARCHAR(30) NOT NULL DEFAULT ''button'' COMMENT ''menu/button/api/field''', 'name');
CALL add_column_if_missing('permissions', 'module', 'VARCHAR(50) NOT NULL DEFAULT '''' COMMENT ''模块''', 'permission_type');
CALL add_column_if_missing('permissions', 'path', 'VARCHAR(255) NOT NULL DEFAULT '''' COMMENT ''前端路由或接口路径''', 'module');
CALL add_column_if_missing('permissions', 'method', 'VARCHAR(20) NOT NULL DEFAULT '''' COMMENT ''接口方法''', 'path');
CALL add_column_if_missing('permissions', 'sort', 'INT NOT NULL DEFAULT 0 COMMENT ''排序''', 'method');
CALL add_column_if_missing('permissions', 'status', 'VARCHAR(32) NOT NULL DEFAULT ''active'' COMMENT ''状态 active/disabled''', 'sort');

DROP PROCEDURE IF EXISTS add_column_if_missing;

INSERT INTO roles (id, code, name, data_scope, status, remark) VALUES
(1, 'super_admin', '超级管理员', 'all', 'active', '拥有全部菜单、按钮、接口、数据和字段权限'),
(2, 'boss', '老板/管理层', 'all', 'active', '查看全局业务数据、报表和敏感金额'),
(3, 'sales_manager', '销售主管', 'team', 'active', '管理团队客户、项目、报价和销售订单'),
(4, 'sales', '销售人员', 'self', 'active', '管理本人客户、项目、报价和销售订单'),
(5, 'purchase_manager', '采购主管', 'all', 'active', '管理采购、供应商和应付业务'),
(6, 'purchase', '采购人员', 'self', 'active', '创建和跟进本人采购订单'),
(7, 'warehouse_manager', '仓库主管', 'all', 'active', '管理库存、入库、出库和SN'),
(8, 'warehouse', '仓库人员', 'all', 'active', '执行入库、出库和SN操作'),
(9, 'finance', '财务人员', 'all', 'active', '管理应收、应付、收款和付款'),
(10, 'aftersales', '售后人员', 'self', 'active', '处理售后工单和质保查询'),
(11, 'product_admin', '产品资料管理员', 'all', 'active', '维护商品、SKU、品牌和价格资料'),
(12, 'auditor', '只读审计员', 'all', 'active', '只读查看业务数据和操作日志')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
data_scope = VALUES(data_scope),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:user:list', '用户列表', 'api', 'system', '/api/v1/system/users', 'GET', 101, 'active'),
('system:user:create', '新增用户', 'api', 'system', '/api/v1/system/users', 'POST', 102, 'active'),
('system:user:update', '编辑用户', 'api', 'system', '/api/v1/system/users/:id', 'PUT', 103, 'active'),
('system:user:delete', '删除用户', 'api', 'system', '/api/v1/system/users/:id', 'DELETE', 104, 'active'),
('system:user:resetPassword', '重置密码', 'button', 'system', '', '', 105, 'active'),
('system:role:list', '角色列表', 'api', 'system', '/api/v1/system/roles', 'GET', 111, 'active'),
('system:role:create', '新增角色', 'api', 'system', '/api/v1/system/roles', 'POST', 112, 'active'),
('system:role:update', '编辑角色', 'api', 'system', '/api/v1/system/roles/:id', 'PUT', 113, 'active'),
('system:role:delete', '删除角色', 'api', 'system', '/api/v1/system/roles/:id', 'DELETE', 114, 'active'),
('system:role:assignPermission', '分配角色权限', 'button', 'system', '', '', 115, 'active'),
('system:permission:list', '权限列表', 'api', 'system', '/api/v1/system/permissions', 'GET', 116, 'active'),
('system:menu:list', '菜单列表', 'api', 'system', '/api/v1/system/menus', 'GET', 121, 'active'),
('system:menu:create', '新增菜单', 'api', 'system', '/api/v1/system/menus', 'POST', 122, 'active'),
('system:menu:update', '编辑菜单', 'api', 'system', '/api/v1/system/menus/:id', 'PUT', 123, 'active'),
('system:menu:delete', '删除菜单', 'api', 'system', '/api/v1/system/menus/:id', 'DELETE', 124, 'active'),
('system:dict:list', '字典列表', 'api', 'system', '/api/v1/system/dicts', 'GET', 131, 'active'),
('system:dict:create', '新增字典', 'api', 'system', '/api/v1/system/dicts', 'POST', 132, 'active'),
('system:dict:update', '编辑字典', 'api', 'system', '/api/v1/system/dicts/:id', 'PUT', 133, 'active'),
('system:dict:delete', '删除字典', 'api', 'system', '/api/v1/system/dicts/:id', 'DELETE', 134, 'active'),
('system:number-rule:list', '编号规则列表', 'api', 'system', '/api/v1/system/number-rules', 'GET', 141, 'active'),
('system:number-rule:create', '新增编号规则', 'api', 'system', '/api/v1/system/number-rules', 'POST', 142, 'active'),
('system:number-rule:update', '编辑编号规则', 'api', 'system', '/api/v1/system/number-rules/:id', 'PUT', 143, 'active'),
('system:number-rule:delete', '删除编号规则', 'api', 'system', '/api/v1/system/number-rules/:id', 'DELETE', 144, 'active'),
('system:numberRule:list', '编号规则列表(兼容)', 'api', 'system', '/api/v1/system/number-rules', 'GET', 145, 'active'),
('system:numberRule:update', '编辑编号规则(兼容)', 'api', 'system', '/api/v1/system/number-rules/:id', 'PUT', 146, 'active'),
('system:operation-log:list', '操作日志列表', 'api', 'system', '/api/v1/system/operation-logs', 'GET', 151, 'active'),
('system:log:list', '操作日志列表(兼容)', 'api', 'system', '/api/v1/system/operation-logs', 'GET', 152, 'active'),
('system:log:export', '导出操作日志', 'button', 'system', '', '', 153, 'active'),

('customer:list', '客户列表', 'api', 'customer', '/api/v1/customers', 'GET', 201, 'active'),
('customer:create', '新增客户', 'api', 'customer', '/api/v1/customers', 'POST', 202, 'active'),
('customer:update', '编辑客户', 'api', 'customer', '/api/v1/customers/:id', 'PUT', 203, 'active'),
('customer:delete', '删除客户', 'api', 'customer', '/api/v1/customers/:id', 'DELETE', 204, 'active'),
('customer:enable', '启用客户', 'button', 'customer', '', '', 205, 'active'),
('customer:disable', '停用客户', 'button', 'customer', '', '', 206, 'active'),
('customer:export', '导出客户', 'button', 'customer', '', '', 207, 'active'),
('customer:import', '导入客户', 'button', 'customer', '', '', 208, 'active'),

('supplier:list', '供应商列表', 'api', 'supplier', '/api/v1/suppliers', 'GET', 301, 'active'),
('supplier:create', '新增供应商', 'api', 'supplier', '/api/v1/suppliers', 'POST', 302, 'active'),
('supplier:update', '编辑供应商', 'api', 'supplier', '/api/v1/suppliers/:id', 'PUT', 303, 'active'),
('supplier:delete', '删除供应商', 'api', 'supplier', '/api/v1/suppliers/:id', 'DELETE', 304, 'active'),
('supplier:enable', '启用供应商', 'button', 'supplier', '', '', 305, 'active'),
('supplier:disable', '停用供应商', 'button', 'supplier', '', '', 306, 'active'),
('supplier:export', '导出供应商', 'button', 'supplier', '', '', 307, 'active'),
('supplier:import', '导入供应商', 'button', 'supplier', '', '', 308, 'active'),

('product:list', '商品列表', 'api', 'product', '/api/v1/products', 'GET', 401, 'active'),
('product:create', '新增商品', 'api', 'product', '/api/v1/products', 'POST', 402, 'active'),
('product:update', '编辑商品', 'api', 'product', '/api/v1/products/:id', 'PUT', 403, 'active'),
('product:delete', '删除商品', 'api', 'product', '/api/v1/products/:id', 'DELETE', 404, 'active'),
('product:enable', '启用商品', 'button', 'product', '', '', 405, 'active'),
('product:disable', '停用商品', 'button', 'product', '', '', 406, 'active'),
('product:export', '导出商品', 'button', 'product', '', '', 407, 'active'),
('product:import', '导入商品', 'button', 'product', '', '', 408, 'active'),
('sku:list', 'SKU列表', 'api', 'sku', '/api/v1/skus', 'GET', 421, 'active'),
('sku:create', '新增SKU', 'api', 'sku', '/api/v1/skus', 'POST', 422, 'active'),
('sku:update', '编辑SKU', 'api', 'sku', '/api/v1/skus/:id', 'PUT', 423, 'active'),
('sku:delete', '删除SKU', 'api', 'sku', '/api/v1/skus/:id', 'DELETE', 424, 'active'),
('sku:enable', '启用SKU', 'button', 'sku', '', '', 425, 'active'),
('sku:disable', '停用SKU', 'button', 'sku', '', '', 426, 'active'),
('sku:viewCost', '查看SKU成本', 'button', 'sku', '', '', 427, 'active'),
('sku:updateCost', '维护SKU成本', 'button', 'sku', '', '', 428, 'active'),
('sku:export', '导出SKU', 'button', 'sku', '', '', 429, 'active'),
('sku:import', '导入SKU', 'button', 'sku', '', '', 430, 'active'),

('warehouse:list', '仓库列表', 'api', 'warehouse', '/api/v1/warehouses', 'GET', 501, 'active'),
('warehouse:create', '新增仓库', 'api', 'warehouse', '/api/v1/warehouses', 'POST', 502, 'active'),
('warehouse:update', '编辑仓库', 'api', 'warehouse', '/api/v1/warehouses/:id', 'PUT', 503, 'active'),
('warehouse:delete', '删除仓库', 'api', 'warehouse', '/api/v1/warehouses/:id', 'DELETE', 504, 'active'),
('warehouse:enable', '启用仓库', 'button', 'warehouse', '', '', 505, 'active'),
('warehouse:disable', '停用仓库', 'button', 'warehouse', '', '', 506, 'active'),
('warehouse:export', '导出仓库', 'button', 'warehouse', '', '', 507, 'active'),
('warehouse:import', '导入仓库', 'button', 'warehouse', '', '', 508, 'active'),

('project:list', '项目列表', 'api', 'project', '/api/v1/projects', 'GET', 601, 'active'),
('project:create', '新增项目', 'api', 'project', '/api/v1/projects', 'POST', 602, 'active'),
('project:update', '编辑项目', 'api', 'project', '/api/v1/projects/:id', 'PUT', 603, 'active'),
('project:delete', '删除项目', 'api', 'project', '/api/v1/projects/:id', 'DELETE', 604, 'active'),
('project:follow', '项目跟进', 'button', 'project', '', '', 605, 'active'),
('project:close', '关闭项目', 'button', 'project', '', '', 606, 'active'),
('project:export', '导出项目', 'button', 'project', '', '', 607, 'active'),

('quotation:list', '报价单列表', 'api', 'quotation', '/api/v1/quotations', 'GET', 701, 'active'),
('quotation:create', '新增报价单', 'api', 'quotation', '/api/v1/quotations', 'POST', 702, 'active'),
('quotation:update', '编辑报价单', 'api', 'quotation', '/api/v1/quotations/:id', 'PUT', 703, 'active'),
('quotation:delete', '删除报价单', 'button', 'quotation', '', '', 704, 'active'),
('quotation:submit', '提交报价单', 'api', 'quotation', '/api/v1/quotations/:id/submit', 'POST', 705, 'active'),
('quotation:audit', '审核报价单', 'api', 'quotation', '/api/v1/quotations/:id/audit', 'POST', 706, 'active'),
('quotation:reject', '驳回报价单', 'api', 'quotation', '/api/v1/quotations/:id/reject', 'POST', 707, 'active'),
('quotation:unaudit', '反审核报价单', 'api', 'quotation', '/api/v1/quotations/:id/unaudit', 'POST', 708, 'active'),
('quotation:confirm', '客户确认报价单', 'api', 'quotation', '/api/v1/quotations/:id/confirm', 'POST', 709, 'active'),
('quotation:convert', '报价转销售订单', 'api', 'quotation', '/api/v1/quotations/:id/convert-to-sales-order', 'POST', 710, 'active'),
('quotation:cancel', '作废报价单', 'api', 'quotation', '/api/v1/quotations/:id/cancel', 'POST', 711, 'active'),
('quotation:copy', '复制报价单', 'button', 'quotation', '', '', 712, 'active'),
('quotation:export', '导出报价单', 'api', 'quotation', '/api/v1/quotations/:id/export', 'GET', 713, 'active'),
('quotation:print', '打印报价单', 'button', 'quotation', '', '', 714, 'active'),
('quotation:viewCost', '查看报价成本', 'button', 'quotation', '', '', 715, 'active'),
('quotation:viewProfit', '查看报价毛利', 'button', 'quotation', '', '', 716, 'active'),
('quotation:attachment', '报价附件', 'button', 'quotation', '', '', 717, 'active'),
('quotation:uploadAttachment', '上传报价附件', 'button', 'quotation', '', '', 718, 'active'),
('quotation:log', '报价日志', 'button', 'quotation', '', '', 719, 'active'),
('quotation:viewLog', '查看报价日志', 'button', 'quotation', '', '', 720, 'active'),

('sales:list', '销售订单列表', 'api', 'sales', '/api/v1/sales-orders', 'GET', 801, 'active'),
('sales:create', '新增销售订单', 'api', 'sales', '/api/v1/sales-orders', 'POST', 802, 'active'),
('sales:update', '编辑销售订单', 'api', 'sales', '/api/v1/sales-orders/:id', 'PUT', 803, 'active'),
('sales:delete', '删除销售订单', 'button', 'sales', '', '', 804, 'active'),
('sales:submit', '提交销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/submit', 'POST', 805, 'active'),
('sales:audit', '审核销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/audit', 'POST', 806, 'active'),
('sales:reject', '驳回销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/reject', 'POST', 807, 'active'),
('sales:unaudit', '反审核销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/unaudit', 'POST', 808, 'active'),
('sales:confirm', '确认销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/confirm', 'POST', 809, 'active'),
('sales:checkStock', '库存检查', 'api', 'sales', '/api/v1/sales-orders/:id/stock-check', 'GET', 810, 'active'),
('sales:generatePurchase', '生成采购', 'api', 'sales', '/api/v1/sales-orders/:id/create-shortage-purchase', 'POST', 811, 'active'),
('sales:outbound', '销售出库', 'api', 'sales', '/api/v1/sales-orders/:id/create-outbound', 'POST', 812, 'active'),
('sales:cancel', '取消销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/cancel', 'POST', 813, 'active'),
('sales:complete', '完成销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/complete', 'POST', 814, 'active'),
('sales:export', '导出销售订单', 'api', 'sales', '/api/v1/sales-orders/:id/export', 'GET', 815, 'active'),
('sales:print', '打印销售订单', 'button', 'sales', '', '', 816, 'active'),
('sales:viewCost', '查看销售成本', 'button', 'sales', '', '', 817, 'active'),
('sales:viewProfit', '查看销售毛利', 'button', 'sales', '', '', 818, 'active'),
('sales:attachment', '销售附件', 'button', 'sales', '', '', 819, 'active'),
('sales:uploadAttachment', '上传销售附件', 'button', 'sales', '', '', 820, 'active'),
('sales:log', '销售日志', 'button', 'sales', '', '', 821, 'active'),
('sales:viewLog', '查看销售日志', 'button', 'sales', '', '', 822, 'active'),

('purchase:list', '采购订单列表', 'api', 'purchase', '/api/v1/purchase-orders', 'GET', 901, 'active'),
('purchase:create', '新增采购订单', 'api', 'purchase', '/api/v1/purchase-orders', 'POST', 902, 'active'),
('purchase:update', '编辑采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id', 'PUT', 903, 'active'),
('purchase:delete', '删除采购订单', 'button', 'purchase', '', '', 904, 'active'),
('purchase:submit', '提交采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/submit', 'POST', 905, 'active'),
('purchase:audit', '审核采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/audit', 'POST', 906, 'active'),
('purchase:reject', '驳回采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/reject', 'POST', 907, 'active'),
('purchase:unaudit', '反审核采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/unaudit', 'POST', 908, 'active'),
('purchase:confirm', '确认采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/confirm', 'POST', 909, 'active'),
('purchase:inbound', '采购入库', 'api', 'purchase', '/api/v1/purchase-orders/:id/create-inbound', 'POST', 910, 'active'),
('purchase:cancel', '取消采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/cancel', 'POST', 911, 'active'),
('purchase:complete', '完成采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/complete', 'POST', 912, 'active'),
('purchase:export', '导出采购订单', 'api', 'purchase', '/api/v1/purchase-orders/:id/export', 'GET', 913, 'active'),
('purchase:print', '打印采购订单', 'button', 'purchase', '', '', 914, 'active'),
('purchase:viewPrice', '查看采购价', 'button', 'purchase', '', '', 915, 'active'),
('purchase:attachment', '采购附件', 'button', 'purchase', '', '', 916, 'active'),
('purchase:uploadAttachment', '上传采购附件', 'button', 'purchase', '', '', 917, 'active'),
('purchase:log', '采购日志', 'button', 'purchase', '', '', 918, 'active'),
('purchase:viewLog', '查看采购日志', 'button', 'purchase', '', '', 919, 'active'),

('inventory:stock:list', '库存现存量列表', 'api', 'inventory', '/api/v1/inventory/stocks', 'GET', 1001, 'active'),
('inventory:stock:viewAmount', '查看库存金额', 'field', 'inventory', '', '', 1002, 'active'),
('inventory:stock:export', '导出库存', 'button', 'inventory', '', '', 1003, 'active'),
('inventory:record:list', '库存流水列表', 'api', 'inventory', '/api/v1/inventory/records', 'GET', 1011, 'active'),
('inventory:record:export', '导出库存流水', 'button', 'inventory', '', '', 1012, 'active'),
('inventory:inbound:list', '入库单列表', 'api', 'inventory', '/api/v1/inventory/inbound-orders', 'GET', 1021, 'active'),
('inventory:inbound:create', '新增入库单', 'api', 'inventory', '/api/v1/inventory/inbound-orders', 'POST', 1022, 'active'),
('inventory:inbound:update', '编辑入库单', 'button', 'inventory', '', '', 1023, 'active'),
('inventory:inbound:confirm', '确认入库', 'api', 'inventory', '/api/v1/inventory/inbound-orders/:id/confirm', 'POST', 1024, 'active'),
('inventory:inbound:cancel', '取消入库单', 'button', 'inventory', '', '', 1025, 'active'),
('inventory:inbound:print', '打印入库单', 'button', 'inventory', '', '', 1026, 'active'),
('inventory:outbound:list', '出库单列表', 'api', 'inventory', '/api/v1/inventory/outbound-orders', 'GET', 1031, 'active'),
('inventory:outbound:create', '新增出库单', 'api', 'inventory', '/api/v1/inventory/outbound-orders', 'POST', 1032, 'active'),
('inventory:outbound:update', '编辑出库单', 'button', 'inventory', '', '', 1033, 'active'),
('inventory:outbound:confirm', '确认出库', 'api', 'inventory', '/api/v1/inventory/outbound-orders/:id/confirm', 'POST', 1034, 'active'),
('inventory:outbound:cancel', '取消出库单', 'button', 'inventory', '', '', 1035, 'active'),
('inventory:outbound:print', '打印出库单', 'button', 'inventory', '', '', 1036, 'active'),
('inventory:export', '导出库存(兼容)', 'button', 'inventory', '', '', 1041, 'active'),

('serial:list', 'SN列表', 'api', 'serial', '/api/v1/serials', 'GET', 1101, 'active'),
('serial:detail', 'SN详情', 'api', 'serial', '/api/v1/serials/:id', 'GET', 1102, 'active'),
('serial:lifecycle', 'SN流转记录', 'button', 'serial', '', '', 1103, 'active'),
('serial:create', '新增SN', 'button', 'serial', '', '', 1104, 'active'),
('serial:update', '编辑SN', 'button', 'serial', '', '', 1105, 'active'),
('serial:export', '导出SN', 'button', 'serial', '', '', 1106, 'active'),
('serial:import', '导入SN', 'button', 'serial', '', '', 1107, 'active'),
('serial:changeStatus', '变更SN状态', 'button', 'serial', '', '', 1108, 'active'),
('serial:viewCustomer', '查看SN客户', 'field', 'serial', '', '', 1109, 'active'),
('serial:viewSalesOrder', '查看SN销售订单', 'field', 'serial', '', '', 1110, 'active'),
('serial:viewWarranty', '查看SN质保', 'field', 'serial', '', '', 1111, 'active'),
('serial:select', '选择SN', 'button', 'serial', '', '', 1112, 'active'),
('serial:scan', '扫码SN', 'button', 'serial', '', '', 1113, 'active'),

('contract:list', '合同列表', 'api', 'contract', '/api/v1/contracts', 'GET', 1201, 'active'),
('contract:create', '新增合同', 'api', 'contract', '/api/v1/contracts', 'POST', 1202, 'active'),
('contract:update', '编辑合同', 'api', 'contract', '/api/v1/contracts/:id', 'PUT', 1203, 'active'),
('contract:cancel', '作废合同', 'api', 'contract', '/api/v1/contracts/:id/cancel', 'POST', 1204, 'active'),
('contract:sign', '签署合同', 'api', 'contract', '/api/v1/contracts/:id/sign', 'POST', 1205, 'active'),
('contract:complete', '完成合同', 'api', 'contract', '/api/v1/contracts/:id/complete', 'POST', 1206, 'active'),
('contract:upload', '上传合同附件', 'api', 'contract', '/api/v1/contracts/:id/files', 'POST', 1207, 'active'),
('contract:download', '下载合同附件', 'api', 'contract', '/api/v1/contracts/files/:fileId/download', 'GET', 1208, 'active'),
('contract:deleteFile', '删除合同附件', 'api', 'contract', '/api/v1/contracts/files/:fileId', 'DELETE', 1209, 'active'),
('contract:delete', '删除合同(兼容)', 'api', 'contract', '/api/v1/contracts/files/:fileId', 'DELETE', 1210, 'active'),
('contract:viewAmount', '查看合同金额', 'field', 'contract', '', '', 1211, 'active'),
('contract:viewLog', '查看合同日志', 'button', 'contract', '', '', 1212, 'active'),
('contract:print', '打印合同', 'button', 'contract', '', '', 1213, 'active'),
('contract:log', '合同日志(兼容)', 'button', 'contract', '', '', 1214, 'active'),
('contract:template:list', '合同模板列表', 'api', 'contract', '/api/v1/contract-templates', 'GET', 1221, 'active'),
('contract:template:create', '新增合同模板', 'api', 'contract', '/api/v1/contract-templates', 'POST', 1222, 'active'),
('contract:template:update', '编辑合同模板', 'api', 'contract', '/api/v1/contract-templates/:id', 'PUT', 1223, 'active'),
('contract:template:delete', '删除合同模板', 'api', 'contract', '/api/v1/contract-templates/:id', 'DELETE', 1224, 'active'),
('contract:template:upload', '上传合同模板', 'button', 'contract', '', '', 1225, 'active'),
('contract:template:download', '下载合同模板', 'api', 'contract', '/api/v1/contract-templates/:id/download', 'GET', 1226, 'active'),
('contract:template:enable', '启用合同模板', 'button', 'contract', '', '', 1227, 'active'),
('contract:template:disable', '停用合同模板', 'button', 'contract', '', '', 1228, 'active'),
('contract:template:setDefault', '设置默认合同模板', 'button', 'contract', '', '', 1229, 'active'),

('finance:receivable:list', '应收列表', 'api', 'finance', '/api/v1/finance/receivables', 'GET', 1301, 'active'),
('finance:receivable:detail', '应收详情', 'button', 'finance', '', '', 1302, 'active'),
('finance:receivable:export', '导出应收', 'button', 'finance', '', '', 1303, 'active'),
('finance:receipt:list', '收款列表', 'api', 'finance', '/api/v1/finance/receipts', 'GET', 1311, 'active'),
('finance:receipt:create', '新增收款', 'api', 'finance', '/api/v1/finance/receipts', 'POST', 1312, 'active'),
('finance:receipt:cancel', '反冲收款', 'button', 'finance', '', '', 1313, 'active'),
('finance:receipt:export', '导出收款', 'button', 'finance', '', '', 1314, 'active'),
('finance:payable:list', '应付列表', 'api', 'finance', '/api/v1/finance/payables', 'GET', 1321, 'active'),
('finance:payable:detail', '应付详情', 'button', 'finance', '', '', 1322, 'active'),
('finance:payable:export', '导出应付', 'button', 'finance', '', '', 1323, 'active'),
('finance:payment:list', '付款列表', 'api', 'finance', '/api/v1/finance/payments', 'GET', 1331, 'active'),
('finance:payment:create', '新增付款', 'api', 'finance', '/api/v1/finance/payments', 'POST', 1332, 'active'),
('finance:payment:cancel', '反冲付款', 'button', 'finance', '', '', 1333, 'active'),
('finance:payment:export', '导出付款', 'button', 'finance', '', '', 1334, 'active'),
('finance:viewAmount', '查看财务金额', 'field', 'finance', '', '', 1341, 'active'),
('finance:list', '财务总览(兼容)', 'api', 'finance', '/api/v1/finance', 'GET', 1342, 'active'),
('finance:export', '导出财务(兼容)', 'button', 'finance', '', '', 1343, 'active'),
('finance:log', '财务日志(兼容)', 'button', 'finance', '', '', 1344, 'active'),
('finance:writeoff', '财务核销(兼容)', 'button', 'finance', '', '', 1345, 'active'),

('aftersales:ticket:list', '售后工单列表', 'api', 'aftersales', '/api/v1/aftersales', 'GET', 1401, 'active'),
('aftersales:ticket:create', '新增售后工单', 'api', 'aftersales', '/api/v1/aftersales', 'POST', 1402, 'active'),
('aftersales:ticket:update', '编辑售后工单', 'api', 'aftersales', '/api/v1/aftersales/:id', 'PUT', 1403, 'active'),
('aftersales:ticket:process', '处理售后工单', 'button', 'aftersales', '', '', 1404, 'active'),
('aftersales:ticket:close', '关闭售后工单', 'button', 'aftersales', '', '', 1405, 'active'),
('aftersales:ticket:cancel', '取消售后工单', 'button', 'aftersales', '', '', 1406, 'active'),
('aftersales:ticket:export', '导出售后工单', 'button', 'aftersales', '', '', 1407, 'active'),
('aftersales:warranty:search', '质保查询', 'api', 'aftersales', '/api/v1/aftersales/warranty', 'GET', 1411, 'active'),
('aftersales:warranty:export', '导出质保', 'button', 'aftersales', '', '', 1412, 'active'),
('aftersales:viewCustomer', '查看售后客户', 'field', 'aftersales', '', '', 1413, 'active'),
('aftersales:viewSN', '查看售后SN', 'field', 'aftersales', '', '', 1414, 'active'),
('aftersales:list', '售后列表(兼容)', 'api', 'aftersales', '/api/v1/aftersales', 'GET', 1415, 'active'),
('aftersales:create', '新增售后(兼容)', 'api', 'aftersales', '/api/v1/aftersales', 'POST', 1416, 'active'),
('aftersales:update', '编辑售后(兼容)', 'api', 'aftersales', '/api/v1/aftersales/:id', 'PUT', 1417, 'active'),
('aftersales:cancel', '取消售后(兼容)', 'button', 'aftersales', '', '', 1418, 'active'),
('aftersales:complete', '完成售后(兼容)', 'button', 'aftersales', '', '', 1419, 'active'),
('aftersales:export', '导出售后(兼容)', 'button', 'aftersales', '', '', 1420, 'active'),
('aftersales:print', '打印售后(兼容)', 'button', 'aftersales', '', '', 1421, 'active'),
('aftersales:attachment', '售后附件(兼容)', 'button', 'aftersales', '', '', 1422, 'active'),
('aftersales:log', '售后日志(兼容)', 'button', 'aftersales', '', '', 1423, 'active'),

('report:sales:view', '销售报表查看', 'api', 'report', '/api/v1/reports/sales', 'GET', 1501, 'active'),
('report:sales:export', '销售报表导出', 'button', 'report', '', '', 1502, 'active'),
('report:purchase:view', '采购报表查看', 'api', 'report', '/api/v1/reports/purchase', 'GET', 1511, 'active'),
('report:purchase:export', '采购报表导出', 'button', 'report', '', '', 1512, 'active'),
('report:inventory:view', '库存报表查看', 'api', 'report', '/api/v1/reports/inventory', 'GET', 1521, 'active'),
('report:inventory:export', '库存报表导出', 'button', 'report', '', '', 1522, 'active'),
('report:finance:view', '财务报表查看', 'api', 'report', '/api/v1/reports/finance', 'GET', 1531, 'active'),
('report:finance:export', '财务报表导出', 'button', 'report', '', '', 1532, 'active'),
('report:aftersales:view', '售后报表查看', 'api', 'report', '/api/v1/reports/aftersales', 'GET', 1541, 'active'),
('report:aftersales:export', '售后报表导出', 'button', 'report', '', '', 1542, 'active'),
('dashboard:view', '工作台查看', 'api', 'dashboard', '/api/v1/dashboard', 'GET', 1551, 'active'),
('report:view', '报表查看(兼容)', 'api', 'report', '/api/v1/reports', 'GET', 1552, 'active'),
('report:sales', '销售报表(兼容)', 'api', 'report', '/api/v1/reports/sales', 'GET', 1553, 'active'),
('report:purchase', '采购报表(兼容)', 'api', 'report', '/api/v1/reports/purchase', 'GET', 1554, 'active'),
('report:inventory', '库存报表(兼容)', 'api', 'report', '/api/v1/reports/inventory', 'GET', 1555, 'active'),
('report:aftersales', '售后报表(兼容)', 'api', 'report', '/api/v1/reports/aftersales', 'GET', 1556, 'active'),

('field:cost_price:view', '查看成本价', 'field', 'field', '', '', 2001, 'active'),
('field:purchase_price:view', '查看采购价', 'field', 'field', '', '', 2002, 'active'),
('field:gross_profit:view', '查看毛利', 'field', 'field', '', '', 2003, 'active'),
('field:gross_margin:view', '查看毛利率', 'field', 'field', '', '', 2004, 'active'),
('field:stock_amount:view', '查看库存金额', 'field', 'field', '', '', 2005, 'active'),
('field:receivable_amount:view', '查看应收金额', 'field', 'field', '', '', 2006, 'active'),
('field:payable_amount:view', '查看应付金额', 'field', 'field', '', '', 2007, 'active'),
('field:customer_credit:view', '查看客户信用额度', 'field', 'field', '', '', 2008, 'active'),
('field:supplier_settlement:view', '查看供应商结算信息', 'field', 'field', '', '', 2009, 'active'),
('field:sensitive_export', '导出敏感数据', 'field', 'field', '', '', 2010, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','suppliers','products','skus','projects','quotations','salesOrders','purchaseOrders','stocks','inventoryRecords','serialNumbers','contract','contractTemplates','contractList','contractFiles','finance','receivables','payables','receipts','payments','reports','salesReport','purchaseReport','inventoryReport','aftersalesReport','systemOperationLogs')
WHERE r.code = 'boss';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('system','masterData','sales','purchase','inventory','contract','finance','reports')
WHERE r.code = 'boss';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','projects','quotations','salesOrders','contract','contractList','aftersales','warrantySearch')
WHERE r.code IN ('sales_manager','sales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','sales','contract','aftersales')
WHERE r.code IN ('sales_manager','sales');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('suppliers','products','skus','purchase','purchaseOrders','contract','contractList','finance','payables')
WHERE r.code IN ('purchase_manager','purchase');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','purchase','contract','finance')
WHERE r.code IN ('purchase_manager','purchase');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('inventory','stocks','inboundOrders','outboundOrders','inventoryRecords','serialNumbers','salesOrders','purchaseOrders')
WHERE r.code IN ('warehouse_manager','warehouse');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('sales','purchase','inventory')
WHERE r.code IN ('warehouse_manager','warehouse');

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('salesOrders','purchaseOrders','contract','contractList','finance','receivables','payables','receipts','payments','reports','salesReport','purchaseReport')
WHERE r.code = 'finance';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('sales','purchase','contract','finance','reports')
WHERE r.code = 'finance';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('aftersales','aftersalesTickets','warrantySearch','serialNumbers','customers','salesOrders')
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData','sales','inventory','aftersales')
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('products','skus','suppliers')
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('masterData')
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('dashboard','customers','suppliers','products','skus','projects','quotations','salesOrders','purchaseOrders','stocks','inventoryRecords','serialNumbers','contract','contractList','finance','receivables','payables','aftersales','aftersalesTickets','reports','salesReport','purchaseReport','inventoryReport','aftersalesReport','systemOperationLogs')
WHERE r.code = 'auditor';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('system','masterData','sales','purchase','inventory','contract','finance','aftersales','reports')
WHERE r.code = 'auditor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'dashboard:view','customer:list','supplier:list','product:list','sku:list','project:list',
    'quotation:list','quotation:viewCost','quotation:viewProfit',
    'sales:list','sales:viewCost','sales:viewProfit',
    'purchase:list','purchase:viewPrice',
    'inventory:stock:list','inventory:stock:viewAmount','inventory:record:list',
    'contract:list','contract:viewAmount','contract:download',
    'finance:receivable:list','finance:payable:list','finance:receipt:list','finance:payment:list','finance:viewAmount',
    'report:sales:view','report:purchase:view','report:inventory:view','report:finance:view','report:aftersales:view',
    'field:cost_price:view','field:purchase_price:view','field:gross_profit:view','field:gross_margin:view',
    'field:stock_amount:view','field:receivable_amount:view','field:payable_amount:view','field:sensitive_export'
)
WHERE r.code = 'boss';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','customer:create','customer:update',
    'project:list','project:create','project:update','project:follow',
    'quotation:list','quotation:create','quotation:update','quotation:submit','quotation:confirm','quotation:convert','quotation:copy','quotation:export','quotation:print','quotation:viewProfit',
    'sales:list','sales:create','sales:update','sales:submit','sales:confirm','sales:checkStock','sales:generatePurchase','sales:export','sales:print','sales:viewProfit',
    'contract:list','contract:create','contract:upload','contract:download',
    'finance:receivable:list','aftersales:warranty:search','field:gross_profit:view','field:gross_margin:view'
)
WHERE r.code = 'sales_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','customer:create','customer:update',
    'project:list','project:create','project:update',
    'quotation:list','quotation:create','quotation:update','quotation:submit','quotation:copy','quotation:export','quotation:print',
    'sales:list','sales:create','sales:update','sales:submit','sales:checkStock',
    'contract:list','contract:create','contract:upload','contract:download',
    'aftersales:warranty:search'
)
WHERE r.code = 'sales';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'supplier:list','supplier:create','supplier:update',
    'product:list','sku:list','sku:viewCost',
    'purchase:list','purchase:create','purchase:update','purchase:submit','purchase:audit','purchase:reject','purchase:unaudit','purchase:confirm','purchase:cancel','purchase:export','purchase:print','purchase:viewPrice',
    'contract:list','contract:create','contract:upload','contract:download',
    'finance:payable:list','report:purchase:view','field:purchase_price:view'
)
WHERE r.code = 'purchase_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'supplier:list','supplier:create','supplier:update',
    'product:list','sku:list',
    'purchase:list','purchase:create','purchase:update','purchase:submit','purchase:export','purchase:print','purchase:viewPrice',
    'contract:list','contract:create','contract:upload','contract:download',
    'field:purchase_price:view'
)
WHERE r.code = 'purchase';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:list','inventory:stock:viewAmount','inventory:record:list',
    'inventory:inbound:list','inventory:inbound:create','inventory:inbound:update','inventory:inbound:confirm','inventory:inbound:cancel','inventory:inbound:print',
    'inventory:outbound:list','inventory:outbound:create','inventory:outbound:update','inventory:outbound:confirm','inventory:outbound:cancel','inventory:outbound:print',
    'serial:list','serial:detail','serial:lifecycle','serial:create','serial:update','serial:changeStatus','serial:export',
    'purchase:list','sales:list','field:stock_amount:view'
)
WHERE r.code = 'warehouse_manager';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:stock:list','inventory:record:list',
    'inventory:inbound:list','inventory:inbound:create','inventory:inbound:confirm',
    'inventory:outbound:list','inventory:outbound:create','inventory:outbound:confirm',
    'serial:list','serial:detail','serial:lifecycle','serial:create','serial:update'
)
WHERE r.code = 'warehouse';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'customer:list','supplier:list','sales:list','purchase:list',
    'contract:list','contract:viewAmount','contract:download',
    'finance:receivable:list','finance:receivable:detail','finance:receipt:list','finance:receipt:create','finance:receipt:cancel',
    'finance:payable:list','finance:payable:detail','finance:payment:list','finance:payment:create','finance:payment:cancel',
    'finance:viewAmount','report:finance:view','report:sales:view','report:purchase:view',
    'field:receivable_amount:view','field:payable_amount:view'
)
WHERE r.code = 'finance';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'aftersales:ticket:list','aftersales:ticket:create','aftersales:ticket:update','aftersales:ticket:process','aftersales:ticket:close','aftersales:warranty:search',
    'serial:list','serial:detail','serial:lifecycle','serial:viewCustomer','serial:viewSalesOrder','serial:viewWarranty',
    'customer:list','sales:list'
)
WHERE r.code = 'aftersales';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'product:list','product:create','product:update','product:delete','product:enable','product:disable','product:import','product:export',
    'sku:list','sku:create','sku:update','sku:delete','sku:enable','sku:disable','sku:updateCost','sku:import','sku:export','sku:viewCost',
    'supplier:list','field:cost_price:view','field:purchase_price:view'
)
WHERE r.code = 'product_admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operation-log:list','system:log:list',
    'customer:list','supplier:list','product:list','sku:list','project:list','quotation:list','sales:list','purchase:list',
    'inventory:stock:list','inventory:record:list','serial:list','contract:list',
    'finance:receivable:list','finance:payable:list','aftersales:ticket:list',
    'report:sales:view','report:purchase:view','report:inventory:view','report:finance:view'
)
WHERE r.code = 'auditor';
