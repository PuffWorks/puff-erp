DROP PROCEDURE IF EXISTS add_index_if_missing;

DELIMITER $$
CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns VARCHAR(255)
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

CALL add_index_if_missing('sales_orders', 'idx_sales_orders_created_at', '`created_at`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_updated_at', '`updated_at`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('sales_orders', 'idx_sales_orders_org_status', '`owner_org_id`,`status`');

CALL add_index_if_missing('quotations', 'idx_quotations_created_at', '`created_at`');
CALL add_index_if_missing('quotations', 'idx_quotations_updated_at', '`updated_at`');
CALL add_index_if_missing('quotations', 'idx_quotations_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('quotations', 'idx_quotations_org_status', '`owner_org_id`,`status`');

CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_created_at', '`created_at`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_updated_at', '`updated_at`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_warehouse', '`warehouse_id`');
CALL add_index_if_missing('purchase_orders', 'idx_purchase_orders_creator_status', '`created_by`,`status`');

CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_warehouse_sku', '`warehouse_id`,`sku_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_sku_warehouse', '`sku_id`,`warehouse_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_available', '`available_qty`');

CALL add_index_if_missing('inventory_records', 'idx_inventory_records_created_at', '`created_at`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_biz_no', '`biz_no`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_type_created', '`biz_type`,`created_at`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_wh_sku', '`warehouse_id`,`sku_id`');

CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_created_at', '`created_at`');
CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_warehouse_status', '`warehouse_id`,`status`');
CALL add_index_if_missing('inventory_inbound_orders', 'idx_inbound_supplier_status', '`supplier_id`,`status`');

CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_created_at', '`created_at`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_warehouse_status', '`warehouse_id`,`status`');
CALL add_index_if_missing('inventory_outbound_orders', 'idx_outbound_customer_status', '`customer_id`,`status`');

CALL add_index_if_missing('receivables', 'idx_receivables_customer_status', '`customer_id`,`status`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_status', '`owner_user_id`,`status`');
CALL add_index_if_missing('receivables', 'idx_receivables_created_at', '`created_at`');
CALL add_index_if_missing('receivables', 'idx_receivables_due_date', '`due_date`');

CALL add_index_if_missing('payables', 'idx_payables_supplier_status', '`supplier_id`,`status`');
CALL add_index_if_missing('payables', 'idx_payables_created_at', '`created_at`');
CALL add_index_if_missing('payables', 'idx_payables_due_date', '`due_date`');

CALL add_index_if_missing('aftersales', 'idx_aftersales_created_at', '`created_at`');
CALL add_index_if_missing('aftersales', 'idx_aftersales_sku_status', '`sku_id`,`status`');

DROP PROCEDURE IF EXISTS add_index_if_missing;
