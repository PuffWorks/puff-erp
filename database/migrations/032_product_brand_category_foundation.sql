-- Product category + brand category foundation for first-phase SKU selection and inventory filtering.

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

CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    category_code VARCHAR(64) NOT NULL,
    category_name VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_product_categories_code (category_code),
    KEY idx_product_categories_parent (parent_id),
    KEY idx_product_categories_status (status),
    KEY idx_product_categories_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

CREATE TABLE IF NOT EXISTS brand_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    category_code VARCHAR(64) NOT NULL,
    category_name VARCHAR(128) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brand_categories_code (category_code),
    KEY idx_brand_categories_parent (parent_id),
    KEY idx_brand_categories_status (status),
    KEY idx_brand_categories_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌分类';

CREATE TABLE IF NOT EXISTS brands (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    brand_category_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    brand_code VARCHAR(64) NOT NULL,
    brand_name VARCHAR(128) NOT NULL,
    logo_file_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    UNIQUE KEY uk_brands_code (brand_code),
    KEY idx_brands_category (brand_category_id),
    KEY idx_brands_status (status),
    KEY idx_brands_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品牌';

CALL add_column_if_missing('products', 'product_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'category');
CALL add_column_if_missing('products', 'brand_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_category_id');
CALL add_column_if_missing('products', 'brand_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'brand_category_id');
CALL add_column_if_missing('skus', 'product_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_id');
CALL add_column_if_missing('skus', 'brand_category_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'product_category_id');
CALL add_column_if_missing('skus', 'brand_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0', 'brand_category_id');

CALL add_index_if_missing('products', 'idx_products_product_category', '`product_category_id`');
CALL add_index_if_missing('products', 'idx_products_brand_category', '`brand_category_id`');
CALL add_index_if_missing('products', 'idx_products_brand_id', '`brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_product_category', '`product_category_id`');
CALL add_index_if_missing('skus', 'idx_skus_brand_category', '`brand_category_id`');
CALL add_index_if_missing('skus', 'idx_skus_brand_id', '`brand_id`');

INSERT INTO product_categories (category_code, category_name, sort, status, remark)
SELECT CONCAT('PC_', UPPER(LEFT(MD5(TRIM(category)), 12))), TRIM(category), 100, 'active', 'Migrated from products.category'
FROM (
    SELECT DISTINCT category
    FROM products
    WHERE deleted_at IS NULL AND TRIM(category) <> ''
) src
ON DUPLICATE KEY UPDATE
category_name = VALUES(category_name),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO brand_categories (category_code, category_name, sort, status, remark)
VALUES ('BC_DEFAULT', '默认品牌分类', 100, 'active', 'Default brand category for migrated brands')
ON DUPLICATE KEY UPDATE
category_name = VALUES(category_name),
updated_at = CURRENT_TIMESTAMP;

INSERT INTO brands (brand_category_id, brand_code, brand_name, sort, status, remark)
SELECT bc.id, CONCAT('BR_', UPPER(LEFT(MD5(TRIM(src.brand)), 12))), TRIM(src.brand), 100, 'active', 'Migrated from products.brand'
FROM (
    SELECT DISTINCT brand
    FROM products
    WHERE deleted_at IS NULL AND TRIM(brand) <> ''
) src
JOIN brand_categories bc ON bc.category_code = 'BC_DEFAULT'
ON DUPLICATE KEY UPDATE
brand_name = VALUES(brand_name),
brand_category_id = VALUES(brand_category_id),
updated_at = CURRENT_TIMESTAMP;

UPDATE products p
LEFT JOIN product_categories pc ON BINARY pc.category_name = BINARY p.category
LEFT JOIN brands b ON BINARY b.brand_name = BINARY p.brand
SET p.product_category_id = COALESCE(pc.id, 0),
    p.brand_id = COALESCE(b.id, 0),
    p.brand_category_id = COALESCE(b.brand_category_id, 0),
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL;

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(58, 4, 'productCategories', 'product-categories', '/product/category/index', '', '商品分类', 'CollectionTag', 3),
(59, 4, 'brandCategories', 'brand-categories', '/brand/category/index', '', '品牌分类', 'PriceTag', 4),
(60, 4, 'brands', 'brands', '/brand/index', '', '品牌管理', 'Discount', 5)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort),
updated_at = CURRENT_TIMESTAMP;

UPDATE menus SET sort = 6, updated_at = CURRENT_TIMESTAMP WHERE name = 'products';
UPDATE menus SET sort = 7, updated_at = CURRENT_TIMESTAMP WHERE name = 'skus';
UPDATE menus SET sort = 8, updated_at = CURRENT_TIMESTAMP WHERE name = 'warehouses';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('productCategory:list', '商品分类列表', 'api', 'product', '/api/v1/product-categories', 'GET', 431, 'active'),
('productCategory:create', '新增商品分类', 'api', 'product', '/api/v1/product-categories', 'POST', 432, 'active'),
('productCategory:update', '编辑商品分类', 'api', 'product', '/api/v1/product-categories/:id', 'PUT', 433, 'active'),
('productCategory:delete', '删除商品分类', 'api', 'product', '/api/v1/product-categories/:id', 'DELETE', 434, 'active'),
('productCategory:enable', '启用商品分类', 'button', 'product', '', '', 435, 'active'),
('productCategory:disable', '停用商品分类', 'button', 'product', '', '', 436, 'active'),
('brandCategory:list', '品牌分类列表', 'api', 'product', '/api/v1/brand-categories', 'GET', 441, 'active'),
('brandCategory:create', '新增品牌分类', 'api', 'product', '/api/v1/brand-categories', 'POST', 442, 'active'),
('brandCategory:update', '编辑品牌分类', 'api', 'product', '/api/v1/brand-categories/:id', 'PUT', 443, 'active'),
('brandCategory:delete', '删除品牌分类', 'api', 'product', '/api/v1/brand-categories/:id', 'DELETE', 444, 'active'),
('brandCategory:enable', '启用品牌分类', 'button', 'product', '', '', 445, 'active'),
('brandCategory:disable', '停用品牌分类', 'button', 'product', '', '', 446, 'active'),
('brand:list', '品牌列表', 'api', 'product', '/api/v1/brands', 'GET', 451, 'active'),
('brand:create', '新增品牌', 'api', 'product', '/api/v1/brands', 'POST', 452, 'active'),
('brand:update', '编辑品牌', 'api', 'product', '/api/v1/brands/:id', 'PUT', 453, 'active'),
('brand:delete', '删除品牌', 'api', 'product', '/api/v1/brands/:id', 'DELETE', 454, 'active'),
('brand:enable', '启用品牌', 'button', 'product', '', '', 455, 'active'),
('brand:disable', '停用品牌', 'button', 'product', '', '', 456, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (58, 59, 60)
WHERE r.code IN ('super_admin', 'boss', 'product_admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'productCategory:list','productCategory:create','productCategory:update','productCategory:delete','productCategory:enable','productCategory:disable',
    'brandCategory:list','brandCategory:create','brandCategory:update','brandCategory:delete','brandCategory:enable','brandCategory:disable',
    'brand:list','brand:create','brand:update','brand:delete','brand:enable','brand:disable'
)
WHERE r.code IN ('super_admin', 'boss', 'product_admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('productCategory:list', 'brandCategory:list', 'brand:list')
WHERE r.code IN ('sales', 'sales_leader', 'sales_manager', 'sales_director', 'purchase', 'purchase_manager', 'warehouse', 'warehouse_manager');

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_column_if_missing;
