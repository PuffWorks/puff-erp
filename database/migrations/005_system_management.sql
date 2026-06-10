CREATE TABLE IF NOT EXISTS system_dicts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_system_dicts_status (status),
    KEY idx_system_dicts_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS system_dict_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    dict_id BIGINT UNSIGNED NOT NULL,
    label VARCHAR(128) NOT NULL,
    value VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_system_dict_item_value (dict_id, value),
    KEY idx_system_dict_items_dict_id (dict_id),
    KEY idx_system_dict_items_status (status),
    KEY idx_system_dict_items_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS number_rules (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    biz_type VARCHAR(32) NOT NULL UNIQUE,
    display_name VARCHAR(128) NOT NULL,
    prefix VARCHAR(16) NOT NULL,
    date_format VARCHAR(32) NOT NULL DEFAULT '20060102',
    sequence_length INT NOT NULL DEFAULT 4,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_number_rules_status (status),
    KEY idx_number_rules_deleted_at (deleted_at)
);

INSERT INTO system_dicts (id, code, name, status, remark) VALUES
(1, 'common_status', 'Common Status', 'active', ''),
(2, 'finance_status', 'Finance Status', 'active', ''),
(3, 'contract_status', 'Contract Status', 'active', ''),
(4, 'writeoff_status', 'Writeoff Status', 'active', '')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO system_dict_items (id, dict_id, label, value, sort, status, remark) VALUES
(1, 1, 'Active', 'active', 1, 'active', ''),
(2, 1, 'Disabled', 'disabled', 2, 'active', ''),
(3, 2, 'Pending', 'pending', 1, 'active', ''),
(4, 2, 'Partial', 'partial', 2, 'active', ''),
(5, 2, 'Paid', 'paid', 3, 'active', ''),
(6, 2, 'Voided', 'voided', 4, 'active', ''),
(7, 3, 'Draft', 'draft', 1, 'active', ''),
(8, 3, 'Signed', 'signed', 2, 'active', ''),
(9, 3, 'Active', 'active', 3, 'active', ''),
(10, 3, 'Completed', 'completed', 4, 'active', ''),
(11, 3, 'Cancelled', 'cancelled', 5, 'active', ''),
(12, 4, 'Done', 'done', 1, 'active', ''),
(13, 4, 'Reversed', 'reversed', 2, 'active', '')
ON DUPLICATE KEY UPDATE
label = VALUES(label),
sort = VALUES(sort),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO number_rules (id, biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
(1, 'quotation', 'Quotation', 'BJ', '20060102', 4, 'active', ''),
(2, 'sales_order', 'Sales Order', 'XS', '20060102', 4, 'active', ''),
(3, 'purchase_order', 'Purchase Order', 'CG', '20060102', 4, 'active', ''),
(4, 'inbound_order', 'Inbound Order', 'RK', '20060102', 4, 'active', ''),
(5, 'outbound_order', 'Outbound Order', 'CK', '20060102', 4, 'active', ''),
(6, 'aftersales', 'Aftersales Ticket', 'SH', '20060102', 4, 'active', ''),
(7, 'receivable', 'Receivable', 'YS', '20060102', 4, 'active', ''),
(8, 'payable', 'Payable', 'YF', '20060102', 4, 'active', ''),
(9, 'receipt', 'Receipt', 'SK', '20060102', 4, 'active', ''),
(10, 'payment', 'Payment', 'FK', '20060102', 4, 'active', ''),
(11, 'writeoff', 'Writeoff', 'HX', '20060102', 4, 'active', ''),
(12, 'contract', 'Contract', 'HT', '20060102', 4, 'active', ''),
(13, 'contract_template', 'Contract Template', 'MB', '20060102', 4, 'active', '')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);
