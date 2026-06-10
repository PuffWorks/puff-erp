-- Finance phase 2 closure: reconciliation, aging, invoices, expenses, and transfer cost carry.

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_def TEXT,
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
        SET @ddl = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_def);
        IF p_after_column IS NOT NULL AND p_after_column <> '' THEN
            SET @ddl = CONCAT(@ddl, ' AFTER `', p_after_column, '`');
        END IF;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_column_if_missing('inventory_outbound_order_items', 'unit_cost', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'unit_price');
CALL add_column_if_missing('inventory_transfer_order_items', 'unit_cost', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'quantity');

CREATE TABLE IF NOT EXISTS finance_invoices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    invoice_no VARCHAR(64) NOT NULL UNIQUE,
    invoice_type VARCHAR(32) NOT NULL,
    source_type VARCHAR(64) NOT NULL DEFAULT '',
    source_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    counterparty_type VARCHAR(32) NOT NULL DEFAULT '',
    counterparty_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    counterparty_name VARCHAR(128) NOT NULL DEFAULT '',
    receivable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    payable_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    receipt_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    payment_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    invoice_date DATE NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'issued',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_fin_invoice_type_status (invoice_type, status),
    KEY idx_fin_invoice_counterparty (counterparty_type, counterparty_id),
    KEY idx_fin_invoice_source (source_type, source_id),
    KEY idx_fin_invoice_receivable (receivable_id),
    KEY idx_fin_invoice_payable (payable_id),
    KEY idx_fin_invoice_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS finance_expense_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    expense_no VARCHAR(64) NOT NULL UNIQUE,
    expense_type VARCHAR(64) NOT NULL,
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    bearer_type VARCHAR(32) NOT NULL DEFAULT '',
    bearer_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    bearer_name VARCHAR(128) NOT NULL DEFAULT '',
    amount DECIMAL(18,4) NOT NULL DEFAULT 0,
    include_cost TINYINT(1) NOT NULL DEFAULT 0,
    attachment_file_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_fin_expense_type_status (expense_type, status),
    KEY idx_fin_expense_biz (biz_type, biz_id),
    KEY idx_fin_expense_bearer (bearer_type, bearer_id),
    KEY idx_fin_expense_include_cost (include_cost),
    KEY idx_fin_expense_deleted_at (deleted_at)
);

INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('finance_invoice', 'Finance Invoice', 'FP', '20060102', 4, 'active', ''),
('finance_expense', 'Finance Expense', 'FY', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    prefix = VALUES(prefix),
    date_format = VALUES(date_format),
    sequence_length = VALUES(sequence_length),
    status = VALUES(status);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('finance:reconciliation:customer', 'Customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation', 'GET', 1351, 'active'),
('finance:reconciliation:customer:export', 'Export customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation/export', 'GET', 1352, 'active'),
('finance:reconciliation:customer:print', 'Print customer reconciliation', 'api', 'finance', '/api/v1/finance/customer-reconciliation/print', 'GET', 1353, 'active'),
('finance:reconciliation:supplier', 'Supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation', 'GET', 1354, 'active'),
('finance:reconciliation:supplier:export', 'Export supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation/export', 'GET', 1355, 'active'),
('finance:reconciliation:supplier:print', 'Print supplier reconciliation', 'api', 'finance', '/api/v1/finance/supplier-reconciliation/print', 'GET', 1356, 'active'),
('finance:aging:receivable', 'Receivable aging', 'api', 'finance', '/api/v1/finance/receivables/aging', 'GET', 1361, 'active'),
('finance:aging:payable', 'Payable aging', 'api', 'finance', '/api/v1/finance/payables/aging', 'GET', 1362, 'active'),
('finance:invoice:list', 'List finance invoices', 'api', 'finance', '/api/v1/finance/invoices', 'GET', 1371, 'active'),
('finance:invoice:create', 'Create finance invoices', 'api', 'finance', '/api/v1/finance/invoices', 'POST', 1372, 'active'),
('finance:invoice:update', 'Update finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id', 'PUT', 1373, 'active'),
('finance:invoice:cancel', 'Cancel finance invoices', 'api', 'finance', '/api/v1/finance/invoices/:id/cancel', 'POST', 1374, 'active'),
('finance:expense:list', 'List finance expenses', 'api', 'finance', '/api/v1/finance/expenses', 'GET', 1381, 'active'),
('finance:expense:create', 'Create finance expenses', 'api', 'finance', '/api/v1/finance/expenses', 'POST', 1382, 'active'),
('finance:expense:update', 'Update finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id', 'PUT', 1383, 'active'),
('finance:expense:confirm', 'Confirm finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/confirm', 'POST', 1384, 'active'),
('finance:expense:cancel', 'Cancel finance expenses', 'api', 'finance', '/api/v1/finance/expenses/:id/cancel', 'POST', 1385, 'active')
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
JOIN permissions p ON p.code IN (
    'finance:reconciliation:customer',
    'finance:reconciliation:customer:export',
    'finance:reconciliation:customer:print',
    'finance:reconciliation:supplier',
    'finance:reconciliation:supplier:export',
    'finance:reconciliation:supplier:print',
    'finance:aging:receivable',
    'finance:aging:payable',
    'finance:invoice:list',
    'finance:invoice:create',
    'finance:invoice:update',
    'finance:invoice:cancel',
    'finance:expense:list',
    'finance:expense:create',
    'finance:expense:update',
    'finance:expense:confirm',
    'finance:expense:cancel'
)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 72, id, 'customerReconciliation', 'customer-reconciliation', '/finance/customer-reconciliation/index', '', '客户对账', 'Connection', 5
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 73, id, 'supplierReconciliation', 'supplier-reconciliation', '/finance/supplier-reconciliation/index', '', '供应商对账', 'Connection', 6
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 74, id, 'receivableAging', 'receivable-aging', '/finance/receivable-aging/index', '', '应收账龄', 'Timer', 7
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 75, id, 'payableAging', 'payable-aging', '/finance/payable-aging/index', '', '应付账龄', 'Timer', 8
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 76, id, 'financeInvoices', 'invoices', '/finance/invoices/index', '', '发票管理', 'Tickets', 9
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
SELECT 77, id, 'financeExpenses', 'expenses', '/finance/expenses/index', '', '费用挂单', 'Money', 10
FROM menus WHERE name = 'finance'
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id), name = VALUES(name), path = VALUES(path), component = VALUES(component), title = VALUES(title), icon = VALUES(icon), sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (72, 73, 74, 75, 76, 77)
WHERE r.code IN ('super_admin', 'admin', 'boss', 'finance');

DROP PROCEDURE IF EXISTS add_column_if_missing;
