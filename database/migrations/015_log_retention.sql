CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    module_name VARCHAR(64) NOT NULL,
    action_name VARCHAR(64) NOT NULL,
    business_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    before_data JSON NULL,
    after_data JSON NULL,
    request_id VARCHAR(64) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_audit_logs_module_name (module_name),
    KEY idx_audit_logs_action_name (action_name),
    KEY idx_audit_logs_business (module_name, business_id),
    KEY idx_audit_logs_created_at (created_at)
);

INSERT IGNORE INTO audit_logs (
    id,
    operator_id,
    module_name,
    action_name,
    business_id,
    business_no,
    before_data,
    after_data,
    request_id,
    created_at
)
SELECT
    id,
    operator_id,
    module_name,
    action_name,
    business_id,
    business_no,
    before_data,
    after_data,
    request_id,
    created_at
FROM operation_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR);

DELETE FROM operation_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

DELETE FROM login_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

DELETE FROM audit_logs
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
