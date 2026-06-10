DELIMITER //

DROP PROCEDURE IF EXISTS add_column_if_missing//
DROP PROCEDURE IF EXISTS add_index_if_missing//

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT,
    IN p_after_column VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ',
            p_column_definition,
            CASE WHEN p_after_column IS NULL OR p_after_column = '' THEN '' ELSE CONCAT(' AFTER `', p_after_column, '`') END
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_columns, ')');
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

CALL add_column_if_missing('receivables', 'source_type', 'VARCHAR(50) NOT NULL DEFAULT ''sales_order'' COMMENT ''来源类型''', 'receivable_no');
CALL add_column_if_missing('receivables', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('receivables', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号''', 'sales_order_id');
CALL add_column_if_missing('receivables', 'customer_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''客户名称''', 'customer_id');
CALL add_column_if_missing('receivables', 'unreceived_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''未收金额''', 'received_amount');
CALL add_column_if_missing('receivables', 'receivable_date', 'DATE NULL COMMENT ''应收日期''', 'status');
CALL add_column_if_missing('receivables', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('receivables', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('payables', 'source_type', 'VARCHAR(50) NOT NULL DEFAULT ''purchase_order'' COMMENT ''来源类型''', 'payable_no');
CALL add_column_if_missing('payables', 'source_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''来源ID''', 'source_type');
CALL add_column_if_missing('payables', 'purchase_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''采购订单号''', 'purchase_order_id');
CALL add_column_if_missing('payables', 'supplier_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''供应商名称''', 'supplier_id');
CALL add_column_if_missing('payables', 'unpaid_amount', 'DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT ''未付金额''', 'paid_amount');
CALL add_column_if_missing('payables', 'payable_date', 'DATE NULL COMMENT ''应付日期''', 'status');
CALL add_column_if_missing('payables', 'owner_user_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购负责人''', 'remark');
CALL add_column_if_missing('payables', 'owner_org_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购团队''', 'owner_user_id');
CALL add_column_if_missing('payables', 'created_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''创建人''', 'owner_org_id');
CALL add_column_if_missing('payables', 'updated_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''更新人''', 'created_by');

CALL add_column_if_missing('receipts', 'receivable_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''应收编号''', 'receivable_id');
CALL add_column_if_missing('receipts', 'sales_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''销售订单ID''', 'receivable_no');
CALL add_column_if_missing('receipts', 'sales_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''销售订单号''', 'sales_order_id');
CALL add_column_if_missing('receipts', 'customer_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''客户名称''', 'customer_id');
CALL add_column_if_missing('receipts', 'receipt_method', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''收款方式''', 'amount');
CALL add_column_if_missing('receipts', 'receipt_date', 'DATE NULL COMMENT ''收款日期''', 'receipt_method');
CALL add_column_if_missing('receipts', 'transaction_no', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''交易流水号''', 'receipt_date');
CALL add_column_if_missing('receipts', 'attachment_file_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''凭证附件ID''', 'transaction_no');
CALL add_column_if_missing('receipts', 'cancelled_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''作废人''', 'created_by');
CALL add_column_if_missing('receipts', 'cancelled_at', 'DATETIME NULL COMMENT ''作废时间''', 'cancelled_by');

CALL add_column_if_missing('payments', 'payable_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''应付编号''', 'payable_id');
CALL add_column_if_missing('payments', 'purchase_order_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''采购订单ID''', 'payable_no');
CALL add_column_if_missing('payments', 'purchase_order_no', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''采购订单号''', 'purchase_order_id');
CALL add_column_if_missing('payments', 'supplier_name', 'VARCHAR(128) NOT NULL DEFAULT '''' COMMENT ''供应商名称''', 'supplier_id');
CALL add_column_if_missing('payments', 'payment_method', 'VARCHAR(32) NOT NULL DEFAULT '''' COMMENT ''付款方式''', 'amount');
CALL add_column_if_missing('payments', 'payment_date', 'DATE NULL COMMENT ''付款日期''', 'payment_method');
CALL add_column_if_missing('payments', 'transaction_no', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''交易流水号''', 'payment_date');
CALL add_column_if_missing('payments', 'attachment_file_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''凭证附件ID''', 'transaction_no');
CALL add_column_if_missing('payments', 'cancelled_by', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''作废人''', 'created_by');
CALL add_column_if_missing('payments', 'cancelled_at', 'DATETIME NULL COMMENT ''作废时间''', 'cancelled_by');

UPDATE receivables r
LEFT JOIN sales_orders so ON so.id = r.sales_order_id
LEFT JOIN customers c ON c.id = r.customer_id
SET r.source_type = 'sales_order',
    r.source_id = CASE WHEN r.source_id = 0 THEN r.sales_order_id ELSE r.source_id END,
    r.sales_order_no = COALESCE(NULLIF(r.sales_order_no, ''), so.sales_order_no, ''),
    r.customer_name = COALESCE(NULLIF(r.customer_name, ''), c.name, ''),
    r.unreceived_amount = GREATEST(r.amount - r.received_amount, 0),
    r.receivable_date = COALESCE(r.receivable_date, DATE(r.created_at)),
    r.status = CASE r.status
        WHEN 'pending' THEN 'unpaid'
        WHEN 'partial' THEN 'partial_paid'
        WHEN 'voided' THEN 'cancelled'
        ELSE r.status
    END;

UPDATE payables p
LEFT JOIN purchase_orders po ON po.id = p.purchase_order_id
LEFT JOIN suppliers s ON s.id = p.supplier_id
LEFT JOIN users u ON u.id = po.created_by
SET p.source_type = 'purchase_order',
    p.source_id = CASE WHEN p.source_id = 0 THEN p.purchase_order_id ELSE p.source_id END,
    p.purchase_order_no = COALESCE(NULLIF(p.purchase_order_no, ''), po.purchase_order_no, ''),
    p.supplier_name = COALESCE(NULLIF(p.supplier_name, ''), s.name, ''),
    p.unpaid_amount = GREATEST(p.amount - p.paid_amount, 0),
    p.payable_date = COALESCE(p.payable_date, DATE(p.created_at)),
    p.owner_user_id = CASE WHEN p.owner_user_id = 0 THEN COALESCE(po.created_by, 0) ELSE p.owner_user_id END,
    p.owner_org_id = CASE WHEN p.owner_org_id = 0 THEN COALESCE(u.organization_id, 0) ELSE p.owner_org_id END,
    p.status = CASE p.status
        WHEN 'pending' THEN 'unpaid'
        WHEN 'partial' THEN 'partial_paid'
        WHEN 'voided' THEN 'cancelled'
        ELSE p.status
    END;

UPDATE receipts rc
LEFT JOIN receivables r ON r.id = rc.receivable_id
SET rc.receivable_no = COALESCE(NULLIF(rc.receivable_no, ''), r.receivable_no, ''),
    rc.sales_order_id = CASE WHEN rc.sales_order_id = 0 THEN COALESCE(r.sales_order_id, 0) ELSE rc.sales_order_id END,
    rc.sales_order_no = COALESCE(NULLIF(rc.sales_order_no, ''), r.sales_order_no, ''),
    rc.customer_name = COALESCE(NULLIF(rc.customer_name, ''), r.customer_name, ''),
    rc.receipt_date = COALESCE(rc.receipt_date, DATE(rc.received_at), DATE(rc.created_at)),
    rc.status = CASE rc.status WHEN 'active' THEN 'confirmed' ELSE rc.status END;

UPDATE payments pm
LEFT JOIN payables p ON p.id = pm.payable_id
SET pm.payable_no = COALESCE(NULLIF(pm.payable_no, ''), p.payable_no, ''),
    pm.purchase_order_id = CASE WHEN pm.purchase_order_id = 0 THEN COALESCE(p.purchase_order_id, 0) ELSE pm.purchase_order_id END,
    pm.purchase_order_no = COALESCE(NULLIF(pm.purchase_order_no, ''), p.purchase_order_no, ''),
    pm.supplier_name = COALESCE(NULLIF(pm.supplier_name, ''), p.supplier_name, ''),
    pm.payment_date = COALESCE(pm.payment_date, DATE(pm.paid_at), DATE(pm.created_at)),
    pm.status = CASE pm.status WHEN 'active' THEN 'confirmed' ELSE pm.status END;

CALL add_index_if_missing('receivables', 'idx_receivables_source', '`source_type`, `source_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_sales_order_no', '`sales_order_no`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_user_id', '`owner_user_id`');
CALL add_index_if_missing('receivables', 'idx_receivables_owner_org_id', '`owner_org_id`');
CALL add_index_if_missing('payables', 'idx_payables_source', '`source_type`, `source_id`');
CALL add_index_if_missing('payables', 'idx_payables_purchase_order_no', '`purchase_order_no`');
CALL add_index_if_missing('payables', 'idx_payables_owner_user_id', '`owner_user_id`');
CALL add_index_if_missing('payables', 'idx_payables_owner_org_id', '`owner_org_id`');
CALL add_index_if_missing('receipts', 'idx_receipts_sales_order_id', '`sales_order_id`');
CALL add_index_if_missing('receipts', 'idx_receipts_status', '`status`');
CALL add_index_if_missing('payments', 'idx_payments_purchase_order_id', '`purchase_order_id`');
CALL add_index_if_missing('payments', 'idx_payments_status', '`status`');

DROP PROCEDURE add_index_if_missing;
DROP PROCEDURE add_column_if_missing;
