DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

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

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
          AND index_name = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('customers', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''客户负责人/销售员ID''', 'status');
CALL add_column_if_missing('customers', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''客户所属机构/团队ID''', 'owner_user_id');
CALL add_column_if_missing('customers', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('customers', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('projects', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''项目所属团队''', 'owner_user_id');
CALL add_column_if_missing('projects', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'remark');
CALL add_column_if_missing('projects', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('quotations', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''报价负责人''', 'converted_sales_order_id');
CALL add_column_if_missing('quotations', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''报价所属团队''', 'owner_user_id');

CALL add_column_if_missing('sales_orders', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售负责人''', 'confirmed_at');
CALL add_column_if_missing('sales_orders', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售所属团队''', 'owner_user_id');

CALL add_column_if_missing('contracts', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同负责人''', 'remark');
CALL add_column_if_missing('contracts', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''合同所属团队''', 'owner_user_id');

CALL add_column_if_missing('receivables', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''应收所属销售负责人''', 'remark');
CALL add_column_if_missing('receivables', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''应收所属销售团队''', 'owner_user_id');

CALL add_column_if_missing('inventory_outbound_orders', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源销售负责人''', 'updated_by');
CALL add_column_if_missing('inventory_outbound_orders', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源销售团队''', 'owner_user_id');

CALL add_index_if_missing('customers', 'idx_customers_owner_user', '`owner_user_id`');
CALL add_index_if_missing('customers', 'idx_customers_owner_org', '`owner_org_id`');
CALL add_index_if_missing('customers', 'idx_customers_created_by', '`created_by`');
CALL add_index_if_missing('projects', 'idx_projects_owner_user', '`owner_user_id`');
CALL add_index_if_missing('projects', 'idx_projects_owner_org', '`owner_org_id`');
CALL add_index_if_missing('projects', 'idx_projects_created_by', '`created_by`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_user', '`owner_user_id`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_org', '`owner_org_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_user', '`owner_user_id`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_org', '`owner_org_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_owner_user', '`owner_user_id`');
CALL add_index_if_missing('contracts', 'idx_contracts_owner_org', '`owner_org_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_user', '`owner_user_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_org', '`owner_org_id`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_owner_user', '`owner_user_id`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_owner_org', '`owner_org_id`');

UPDATE customers SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE customers SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE customers c LEFT JOIN users u ON u.id = c.owner_user_id SET c.owner_org_id = u.organization_id WHERE c.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE customers SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE customers SET created_by = owner_user_id WHERE created_by = 0;
UPDATE customers SET updated_by = created_by WHERE updated_by = 0;

UPDATE projects SET created_by = owner_user_id WHERE created_by = 0 AND owner_user_id > 0;
UPDATE projects SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE projects SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE projects p LEFT JOIN users u ON u.id = p.owner_user_id SET p.owner_org_id = u.organization_id WHERE p.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE projects SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE projects SET created_by = owner_user_id WHERE created_by = 0;
UPDATE projects SET updated_by = created_by WHERE updated_by = 0;

UPDATE quotations SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE quotations SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE quotations q LEFT JOIN users u ON u.id = q.owner_user_id SET q.owner_org_id = u.organization_id WHERE q.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE quotations SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE sales_orders SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE sales_orders SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE sales_orders s LEFT JOIN users u ON u.id = s.owner_user_id SET s.owner_org_id = u.organization_id WHERE s.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE sales_orders SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE contracts SET owner_user_id = created_by WHERE owner_user_id = 0 AND created_by > 0;
UPDATE contracts SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE contracts c LEFT JOIN users u ON u.id = c.owner_user_id SET c.owner_org_id = u.organization_id WHERE c.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE contracts SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE receivables r
JOIN sales_orders s ON s.id = r.sales_order_id
SET r.owner_user_id = s.owner_user_id, r.owner_org_id = s.owner_org_id
WHERE r.owner_user_id = 0 OR r.owner_org_id = 0;
UPDATE receivables SET owner_user_id = 1 WHERE owner_user_id = 0 AND EXISTS (SELECT 1 FROM users WHERE id = 1);
UPDATE receivables r LEFT JOIN users u ON u.id = r.owner_user_id SET r.owner_org_id = u.organization_id WHERE r.owner_org_id = 0 AND u.organization_id IS NOT NULL;
UPDATE receivables SET owner_org_id = 1 WHERE owner_org_id = 0;

UPDATE inventory_outbound_orders o
JOIN sales_orders s ON s.id = o.source_sales_order_id
SET o.owner_user_id = s.owner_user_id, o.owner_org_id = s.owner_org_id
WHERE o.source_sales_order_id > 0 AND (o.owner_user_id = 0 OR o.owner_org_id = 0);

UPDATE roles SET data_scope = 'all' WHERE code IN ('super_admin', 'admin', 'boss');
UPDATE roles SET data_scope = 'team' WHERE code IN ('sales_manager');
UPDATE roles SET data_scope = 'self' WHERE code IN ('sales');

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('customer:transfer', '客户转移', 'api', 'customer', '/api/v1/customers/:id/transfer', 'POST', 209, 'active'),
('customer:assignOwner', '指定客户负责人', 'button', 'customer', '', '', 210, 'active'),
('field:stock_qty:view', '查看库存数量', 'field', 'field', '', '', 2011, 'active'),
('field:available_qty:view', '查看可用库存', 'field', 'field', '', '', 2012, 'active')
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
JOIN permissions p ON p.code IN ('customer:transfer','customer:assignOwner','field:stock_qty:view','field:available_qty:view')
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('field:stock_qty:view','field:available_qty:view')
WHERE r.code IN ('sales', 'sales_manager', 'purchase', 'purchase_manager', 'warehouse', 'warehouse_manager', 'finance');

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code IN ('warehouse', 'warehouse_manager')
  AND p.code IN ('inventory:stock:viewAmount', 'field:stock_amount:view');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
