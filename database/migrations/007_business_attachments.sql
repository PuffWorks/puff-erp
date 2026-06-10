CREATE TABLE IF NOT EXISTS business_attachments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    business_type VARCHAR(64) NOT NULL,
    business_id BIGINT UNSIGNED NOT NULL,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL DEFAULT '',
    file_size BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    KEY idx_business_attachments_biz (business_type, business_id),
    KEY idx_business_attachments_status (status),
    KEY idx_business_attachments_uploaded_at (uploaded_at)
);
