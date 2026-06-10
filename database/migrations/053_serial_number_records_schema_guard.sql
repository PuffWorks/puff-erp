-- Ensure SN status changes have a traceable business source even on databases
-- imported from older snapshots that did not include migration 044.

CREATE TABLE IF NOT EXISTS serial_number_records (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    sn_id BIGINT UNSIGNED NOT NULL,
    sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL,
    biz_type VARCHAR(64) NOT NULL DEFAULT '',
    biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    biz_no VARCHAR(64) NOT NULL DEFAULT '',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sn_records_sn_id (sn_id),
    KEY idx_sn_records_sn_code (sn_code),
    KEY idx_sn_records_biz (biz_type, biz_id),
    KEY idx_sn_records_created_at (created_at)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE serial_number_records
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    MODIFY sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    MODIFY from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    MODIFY to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL;
