-- Upgrade master data linkage for product category, brand category, brand, product, SKU, and stock views.

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;

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

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
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

CALL add_column_if_missing('product_categories', 'default_unit', 'VARCHAR(32) NOT NULL DEFAULT ''''', 'category_name');
CALL add_column_if_missing('product_categories', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'default_unit');
CALL add_column_if_missing('product_categories', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_stock_item');
CALL add_column_if_missing('product_categories', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');

CALL add_column_if_missing('brands', 'brand_short_name', 'VARCHAR(64) NOT NULL DEFAULT ''''', 'brand_name');
CALL add_column_if_missing('brands', 'brand_en_name', 'VARCHAR(128) NOT NULL DEFAULT ''''', 'brand_short_name');
CALL add_column_if_missing('brands', 'default_supplier_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'logo_file_id');
CALL add_column_if_missing('brands', 'is_common', 'TINYINT(1) NOT NULL DEFAULT 0', 'default_supplier_id');
CALL add_column_if_missing('brands', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_common');
CALL add_column_if_missing('brands', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');
CALL add_column_if_missing('brands', 'show_in_quotation', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_purchase');
CALL add_column_if_missing('brands', 'show_in_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'show_in_quotation');

CALL add_column_if_missing('products', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'unit');
CALL add_column_if_missing('products', 'allow_sales', 'TINYINT(1) NOT NULL DEFAULT 1', 'is_stock_item');
CALL add_column_if_missing('products', 'allow_purchase', 'TINYINT(1) NOT NULL DEFAULT 1', 'allow_sales');

CALL add_column_if_missing('skus', 'model', 'VARCHAR(128) NOT NULL DEFAULT ''''', 'spec');
CALL add_column_if_missing('skus', 'stock_warning_qty', 'DECIMAL(18,4) NOT NULL DEFAULT 0', 'purchase_price');
CALL add_column_if_missing('skus', 'is_stock_item', 'TINYINT(1) NOT NULL DEFAULT 1', 'stock_warning_qty');
CALL add_column_if_missing('skus', 'remark', 'VARCHAR(500) NOT NULL DEFAULT ''''', 'is_stock_item');

CALL add_index_if_missing('brands', 'idx_brands_default_supplier', '`default_supplier_id`');

CREATE TABLE IF NOT EXISTS brand_category_product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_category_id BIGINT UNSIGNED NOT NULL,
    product_category_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_category_product_category (brand_category_id, product_category_id),
    KEY idx_bcpc_brand_category (brand_category_id),
    KEY idx_bcpc_product_category (product_category_id),
    KEY idx_bcpc_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌分类适用商品分类';

CREATE TABLE IF NOT EXISTS brand_product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_id BIGINT UNSIGNED NOT NULL,
    product_category_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_product_category (brand_id, product_category_id),
    KEY idx_bpc_brand (brand_id),
    KEY idx_bpc_product_category (product_category_id),
    KEY idx_bpc_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌适用商品分类';

INSERT IGNORE INTO brand_category_product_categories (brand_category_id, product_category_id)
SELECT DISTINCT p.brand_category_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_category_id > 0
  AND p.product_category_id > 0;

INSERT IGNORE INTO brand_product_categories (brand_id, product_category_id)
SELECT DISTINCT p.brand_id, p.product_category_id
FROM products p
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0
  AND p.product_category_id > 0;

UPDATE products p
JOIN brands b ON b.id = p.brand_id
SET p.brand_category_id = b.brand_category_id,
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0;

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.model = IF(s.model = '', p.model, s.model),
    s.is_stock_item = p.is_stock_item,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL;

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_column_if_missing;
