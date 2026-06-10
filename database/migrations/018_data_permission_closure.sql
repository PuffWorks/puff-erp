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

CALL add_column_if_missing('aftersales', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''售后关联销售负责人/归属人''', 'sku_id');
CALL add_column_if_missing('aftersales', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''售后关联销售团队/归属团队''', 'owner_user_id');
CALL add_column_if_missing('aftersales', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'closed_at');
CALL add_column_if_missing('aftersales', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_index_if_missing('aftersales', 'idx_aftersales_owner_user', '`owner_user_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_owner_org', '`owner_org_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sales_order', '`sales_order_id`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_created_by', '`created_by`');

UPDATE aftersales a
JOIN sales_orders s ON s.id = a.sales_order_id
SET a.owner_user_id = s.owner_user_id,
    a.owner_org_id = s.owner_org_id
WHERE a.sales_order_id > 0
  AND (a.owner_user_id = 0 OR a.owner_org_id = 0);

UPDATE aftersales a
JOIN customers c ON c.id = a.customer_id
SET a.owner_user_id = c.owner_user_id,
    a.owner_org_id = c.owner_org_id
WHERE a.customer_id > 0
  AND (a.owner_user_id = 0 OR a.owner_org_id = 0);

UPDATE aftersales
SET owner_user_id = 1
WHERE owner_user_id = 0
  AND EXISTS (SELECT 1 FROM users WHERE id = 1);

UPDATE aftersales a
LEFT JOIN users u ON u.id = a.owner_user_id
SET a.owner_org_id = u.organization_id
WHERE a.owner_org_id = 0
  AND u.organization_id IS NOT NULL;

UPDATE aftersales SET owner_org_id = 1 WHERE owner_org_id = 0;
UPDATE aftersales SET created_by = owner_user_id WHERE created_by = 0;
UPDATE aftersales SET updated_by = created_by WHERE updated_by = 0;

UPDATE roles SET data_scope = 'all' WHERE code = 'aftersales';

DELETE rp FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'aftersales'
  AND p.code IN ('customer:list', 'sales:list');

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
