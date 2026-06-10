-- Normalize SN record text columns on databases where the table was created
-- under MySQL 8's utf8mb4_0900_ai_ci default while older tables use
-- utf8mb4_unicode_ci.

ALTER TABLE serial_number_records
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    MODIFY sn_code VARCHAR(128) COLLATE utf8mb4_unicode_ci NOT NULL,
    MODIFY from_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    MODIFY to_status VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL;
