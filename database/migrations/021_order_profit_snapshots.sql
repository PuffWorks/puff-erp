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

CALL add_column_if_missing('quotation_items', 'cost_price', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('quotation_items', 'gross_profit', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'amount');
CALL add_column_if_missing('quotation_items', 'gross_margin', 'DECIMAL(10,4) NOT NULL DEFAULT 0', 'gross_profit');

CALL add_column_if_missing('sales_order_items', 'cost_price', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('sales_order_items', 'gross_profit', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'amount');
CALL add_column_if_missing('sales_order_items', 'gross_margin', 'DECIMAL(10,4) NOT NULL DEFAULT 0', 'gross_profit');

UPDATE quotation_items qi
JOIN skus s ON s.id = qi.sku_id
SET qi.cost_price = s.cost_price
WHERE qi.cost_price = 0;

UPDATE quotation_items
SET gross_profit = amount - (quantity * cost_price),
    gross_margin = CASE WHEN amount > 0 THEN (amount - (quantity * cost_price)) / amount ELSE 0 END;

UPDATE sales_order_items soi
JOIN skus s ON s.id = soi.sku_id
SET soi.cost_price = s.cost_price
WHERE soi.cost_price = 0;

UPDATE sales_order_items
SET gross_profit = amount - (quantity * cost_price),
    gross_margin = CASE WHEN amount > 0 THEN (amount - (quantity * cost_price)) / amount ELSE 0 END;

DROP PROCEDURE IF EXISTS add_column_if_missing;
