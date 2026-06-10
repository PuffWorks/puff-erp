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

CALL add_column_if_missing('operation_logs', 'request_path', 'VARCHAR(255) NOT NULL DEFAULT ''''', 'business_no');
CALL add_column_if_missing('operation_logs', 'request_method', 'VARCHAR(20) NOT NULL DEFAULT ''''', 'request_path');
CALL add_column_if_missing('operation_logs', 'request_params', 'TEXT NULL', 'request_method');
CALL add_column_if_missing('operation_logs', 'result', 'VARCHAR(32) NOT NULL DEFAULT ''success''', 'request_params');
CALL add_column_if_missing('operation_logs', 'ip_address', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'result');
CALL add_index_if_missing('operation_logs', 'idx_operation_logs_request_path', '`request_path`(191)');
CALL add_index_if_missing('operation_logs', 'idx_operation_logs_ip_address', '`ip_address`');

CALL add_column_if_missing('audit_logs', 'request_path', 'VARCHAR(255) NOT NULL DEFAULT ''''', 'business_no');
CALL add_column_if_missing('audit_logs', 'request_method', 'VARCHAR(20) NOT NULL DEFAULT ''''', 'request_path');
CALL add_column_if_missing('audit_logs', 'request_params', 'TEXT NULL', 'request_method');
CALL add_column_if_missing('audit_logs', 'result', 'VARCHAR(32) NOT NULL DEFAULT ''success''', 'request_params');
CALL add_column_if_missing('audit_logs', 'ip_address', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'result');
CALL add_index_if_missing('audit_logs', 'idx_audit_logs_request_path', '`request_path`(191)');
CALL add_index_if_missing('audit_logs', 'idx_audit_logs_ip_address', '`ip_address`');

DROP PROCEDURE add_index_if_missing;
DROP PROCEDURE add_column_if_missing;
