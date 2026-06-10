-- Normalize visible names and existing message content to Simplified Chinese.
-- Safe to run repeatedly.

UPDATE users
SET display_name = '系统管理员'
WHERE username = 'admin' AND display_name IN ('System Admin', 'Admin', 'Administrator');

UPDATE roles
SET name = '超级管理员'
WHERE code = 'super_admin' AND name IN ('Super Admin', 'Administrator');

UPDATE permissions
SET name = CASE code
    WHEN 'message:list' THEN '查看消息'
    WHEN 'message:todo:list' THEN '查看待办消息'
    WHEN 'message:read' THEN '标记消息已读'
    WHEN 'message:todo:done' THEN '完成待办消息'
    WHEN 'message:delete' THEN '删除消息'
    ELSE name
END
WHERE code IN ('message:list','message:todo:list','message:read','message:todo:done','message:delete');

UPDATE menus
SET title = CASE name
    WHEN 'dashboard' THEN '工作台'
    WHEN 'system' THEN '系统管理'
    WHEN 'systemUsers' THEN '用户管理'
    WHEN 'systemRoles' THEN '角色管理'
    WHEN 'systemMenus' THEN '菜单管理'
    WHEN 'systemOrganizations' THEN '组织架构'
    WHEN 'systemDicts' THEN '字典管理'
    WHEN 'systemFiles' THEN '文件管理'
    WHEN 'systemLoginLogs' THEN '登录日志'
    WHEN 'systemOperationLogs' THEN '操作日志'
    WHEN 'systemNumberRules' THEN '编号规则'
    WHEN 'masterData' THEN '基础资料'
    WHEN 'customers' THEN '客户管理'
    WHEN 'suppliers' THEN '供应商管理'
    WHEN 'products' THEN '商品管理'
    WHEN 'skus' THEN '商品SKU'
    WHEN 'warehouses' THEN '仓库管理'
    WHEN 'sales' THEN '销售管理'
    WHEN 'quotations' THEN '报价单'
    WHEN 'salesOrders' THEN '销售订单'
    WHEN 'projects' THEN '项目管理'
    WHEN 'inventory' THEN '库存管理'
    WHEN 'stocks' THEN '当前库存'
    WHEN 'inboundOrders' THEN '入库单'
    WHEN 'outboundOrders' THEN '出库单'
    WHEN 'inventoryRecords' THEN '库存流水'
    WHEN 'serialNumbers' THEN '序列号管理'
    WHEN 'contract' THEN '合同管理'
    WHEN 'contractTemplates' THEN '合同模板'
    WHEN 'contractList' THEN '合同列表'
    WHEN 'contractFiles' THEN '合同附件'
    WHEN 'purchase' THEN '采购管理'
    WHEN 'purchaseOrders' THEN '采购订单'
    WHEN 'aftersales' THEN '售后管理'
    WHEN 'aftersalesTickets' THEN '售后工单'
    WHEN 'warrantySearch' THEN '质保查询'
    WHEN 'finance' THEN '财务管理'
    WHEN 'receivables' THEN '应收记录'
    WHEN 'payables' THEN '应付记录'
    WHEN 'receipts' THEN '收款记录'
    WHEN 'payments' THEN '付款记录'
    WHEN 'reports' THEN '报表中心'
    WHEN 'salesReport' THEN '销售报表'
    WHEN 'purchaseReport' THEN '采购报表'
    WHEN 'inventoryReport' THEN '库存报表'
    WHEN 'aftersalesReport' THEN '售后报表'
    WHEN 'messageCenter' THEN '消息中心'
    WHEN 'myMessages' THEN '我的消息'
    WHEN 'myTodos' THEN '我的待办'
    WHEN 'dataImport' THEN '数据导入'
    WHEN 'importTasks' THEN '导入任务'
    WHEN 'importLogs' THEN '导入日志'
    ELSE title
END
WHERE name IN (
    'dashboard','system','systemUsers','systemRoles','systemMenus','systemOrganizations',
    'systemDicts','systemFiles','systemLoginLogs','systemOperationLogs','systemNumberRules',
    'masterData','customers','suppliers','products','skus','warehouses','sales','quotations',
    'salesOrders','projects','inventory','stocks','inboundOrders','outboundOrders',
    'inventoryRecords','serialNumbers','contract','contractTemplates','contractList',
    'contractFiles','purchase','purchaseOrders','aftersales','aftersalesTickets',
    'warrantySearch','finance','receivables','payables','receipts','payments','reports',
    'salesReport','purchaseReport','inventoryReport','aftersalesReport','messageCenter',
    'myMessages','myTodos','dataImport','importTasks','importLogs'
);

UPDATE messages
SET title = '采购订单待入库'
WHERE title = 'purchase order pending inbound';

UPDATE messages
SET title = '采购入库待处理'
WHERE title = 'purchase inbound pending';

UPDATE messages
SET content = CONCAT('采购订单 ', biz_no, ' 已确认，请处理入库和应付')
WHERE content LIKE 'purchase order % confirmed, please handle inbound and payable';

UPDATE messages
SET content = REPLACE(REPLACE(content, 'purchase order ', '采购订单 '), ' generated inbound order ', ' 已生成入库单 ')
WHERE content LIKE 'purchase order % generated inbound order %';
