-- Harden master data linkage rules for product categories, brand categories,
-- brands, products, SKUs, warehouses, and stock filters.
-- Safe to run repeatedly.

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS exec_if_table_exists;

DELIMITER $$

CREATE PROCEDURE add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) AND NOT EXISTS (
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

CREATE PROCEDURE exec_if_table_exists(
    IN p_table_name VARCHAR(64),
    IN p_sql TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = p_table_name
    ) THEN
        SET @ddl = p_sql;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

CALL add_index_if_missing('brand_category_product_categories', 'idx_bcpc_product_brand_category', '`product_category_id`, `brand_category_id`');
CALL add_index_if_missing('brand_product_categories', 'idx_bpc_product_brand', '`product_category_id`, `brand_id`');

CALL add_index_if_missing('brands', 'idx_brands_category_status', '`brand_category_id`, `status`, `deleted_at`');
CALL add_index_if_missing('products', 'idx_products_taxonomy', '`product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('products', 'idx_products_brand_category_brand', '`brand_category_id`, `brand_id`');
CALL add_index_if_missing('products', 'idx_products_category_status', '`product_category_id`, `status`, `deleted_at`');
CALL add_index_if_missing('skus', 'idx_skus_taxonomy', '`product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_product_taxonomy', '`product_id`, `product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('skus', 'idx_skus_status_taxonomy', '`status`, `product_category_id`, `brand_category_id`, `brand_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_product_sku_wh', '`product_id`, `sku_id`, `warehouse_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_warehouse_product', '`warehouse_id`, `product_id`');
CALL add_index_if_missing('inventory_stocks', 'idx_inventory_stocks_sku_stock', '`sku_id`, `stock_qty`, `available_qty`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_records', 'idx_inventory_records_warehouse_created', '`warehouse_id`, `created_at`');
CALL add_index_if_missing('quotation_items', 'idx_quotation_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('sales_order_items', 'idx_sales_order_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('purchase_order_items', 'idx_purchase_order_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_inbound_order_items', 'idx_inbound_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('inventory_outbound_order_items', 'idx_outbound_items_product_sku', '`product_id`, `sku_id`');
CALL add_index_if_missing('serial_numbers', 'idx_serial_numbers_product_sku_wh', '`product_id`, `sku_id`, `warehouse_id`');
CALL add_index_if_missing('serial_numbers', 'idx_serial_numbers_sku_status_wh', '`sku_id`, `status`, `warehouse_id`');
CALL add_index_if_missing('inventory_check_orders', 'idx_inventory_check_filter', '`warehouse_id`, `product_category_id`, `brand_category_id`, `brand_id`, `status`');
CALL add_index_if_missing('inventory_check_items', 'idx_inventory_check_item_filter', '`warehouse_id`, `product_category_id`, `brand_category_id`, `brand_id`, `sku_id`');

-- Linkage tables are maintained as current-state rule sets. Physically remove
-- soft-deleted or orphaned rows so unique keys do not block re-adding a rule.
DELETE bcpc
FROM brand_category_product_categories bcpc
LEFT JOIN brand_categories bc ON bc.id = bcpc.brand_category_id
LEFT JOIN product_categories pc ON pc.id = bcpc.product_category_id
WHERE bcpc.deleted_at IS NOT NULL
   OR bcpc.brand_category_id = 0
   OR bcpc.product_category_id = 0
   OR bc.id IS NULL
   OR pc.id IS NULL
   OR bc.deleted_at IS NOT NULL
   OR pc.deleted_at IS NOT NULL;

DELETE bpc
FROM brand_product_categories bpc
LEFT JOIN brands b ON b.id = bpc.brand_id
LEFT JOIN product_categories pc ON pc.id = bpc.product_category_id
WHERE bpc.deleted_at IS NOT NULL
   OR bpc.brand_id = 0
   OR bpc.product_category_id = 0
   OR b.id IS NULL
   OR pc.id IS NULL
   OR b.deleted_at IS NOT NULL
   OR pc.deleted_at IS NOT NULL;

-- Backfill missing applicable product-category scopes from existing business data.
INSERT IGNORE INTO brand_category_product_categories (brand_category_id, product_category_id)
SELECT DISTINCT b.brand_category_id, bpc.product_category_id
FROM brands b
JOIN brand_product_categories bpc ON bpc.brand_id = b.id
WHERE b.deleted_at IS NULL
  AND b.brand_category_id > 0
  AND bpc.product_category_id > 0;

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

-- For brands that have no explicit scope rows, inherit the product-category
-- scope from their brand category so existing migrated brands remain usable.
INSERT IGNORE INTO brand_product_categories (brand_id, product_category_id)
SELECT DISTINCT b.id, bcpc.product_category_id
FROM brands b
JOIN brand_category_product_categories bcpc ON bcpc.brand_category_id = b.brand_category_id
LEFT JOIN brand_product_categories existing ON existing.brand_id = b.id
WHERE b.deleted_at IS NULL
  AND b.id > 0
  AND b.brand_category_id > 0
  AND bcpc.product_category_id > 0
  AND existing.id IS NULL;

-- Ensure product and SKU taxonomy snapshots follow the selected brand.
UPDATE products p
JOIN brands b ON b.id = p.brand_id
SET p.brand = b.brand_name,
    p.brand_category_id = b.brand_category_id,
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.brand_id > 0
  AND (BINARY p.brand <> BINARY b.brand_name OR p.brand_category_id <> b.brand_category_id);

UPDATE products p
JOIN product_categories pc ON pc.id = p.product_category_id
SET p.category = pc.category_name,
    p.unit = IF(p.unit = '', pc.default_unit, p.unit),
    p.updated_at = CURRENT_TIMESTAMP
WHERE p.deleted_at IS NULL
  AND p.product_category_id > 0
  AND (BINARY p.category <> BINARY pc.category_name OR (p.unit = '' AND pc.default_unit <> ''));

UPDATE skus s
JOIN products p ON p.id = s.product_id
SET s.product_category_id = p.product_category_id,
    s.brand_category_id = p.brand_category_id,
    s.brand_id = p.brand_id,
    s.model = IF(s.model = '', p.model, s.model),
    s.is_stock_item = p.is_stock_item,
    s.updated_at = CURRENT_TIMESTAMP
WHERE s.deleted_at IS NULL
  AND (
      s.product_category_id <> p.product_category_id
      OR s.brand_category_id <> p.brand_category_id
      OR s.brand_id <> p.brand_id
      OR (BINARY s.model = BINARY '' AND BINARY p.model <> BINARY '')
      OR s.is_stock_item <> p.is_stock_item
  );

UPDATE inventory_stocks ist
JOIN skus s ON s.id = ist.sku_id
SET ist.product_id = s.product_id,
    ist.updated_at = CURRENT_TIMESTAMP
WHERE ist.product_id <> s.product_id;

UPDATE inventory_records ir
JOIN skus s ON s.id = ir.sku_id
SET ir.product_id = s.product_id
WHERE ir.product_id <> s.product_id;

UPDATE quotation_items qi
JOIN skus s ON s.id = qi.sku_id
SET qi.product_id = s.product_id,
    qi.updated_at = CURRENT_TIMESTAMP
WHERE qi.product_id <> s.product_id;

UPDATE sales_order_items soi
JOIN skus s ON s.id = soi.sku_id
SET soi.product_id = s.product_id,
    soi.updated_at = CURRENT_TIMESTAMP
WHERE soi.product_id <> s.product_id;

UPDATE purchase_order_items poi
JOIN skus s ON s.id = poi.sku_id
SET poi.product_id = s.product_id,
    poi.updated_at = CURRENT_TIMESTAMP
WHERE poi.product_id <> s.product_id;

UPDATE inventory_inbound_order_items ioi
JOIN skus s ON s.id = ioi.sku_id
SET ioi.product_id = s.product_id,
    ioi.updated_at = CURRENT_TIMESTAMP
WHERE ioi.product_id <> s.product_id;

UPDATE inventory_outbound_order_items ooi
JOIN skus s ON s.id = ooi.sku_id
SET ooi.product_id = s.product_id,
    ooi.updated_at = CURRENT_TIMESTAMP
WHERE ooi.product_id <> s.product_id;

UPDATE serial_numbers sn
JOIN skus s ON s.id = sn.sku_id
SET sn.product_id = s.product_id,
    sn.updated_at = CURRENT_TIMESTAMP
WHERE sn.product_id <> s.product_id;

CALL exec_if_table_exists('inventory_check_orders', 'UPDATE inventory_check_orders ico JOIN warehouses w ON w.id = ico.warehouse_id SET ico.warehouse_name = w.name, ico.updated_at = CURRENT_TIMESTAMP WHERE BINARY ico.warehouse_name <> BINARY w.name');

CALL exec_if_table_exists('inventory_check_items', 'UPDATE inventory_check_items ici JOIN skus s ON s.id = ici.sku_id LEFT JOIN products p ON p.id = s.product_id LEFT JOIN product_categories pc ON pc.id = s.product_category_id LEFT JOIN brand_categories bc ON bc.id = s.brand_category_id LEFT JOIN brands b ON b.id = s.brand_id LEFT JOIN warehouses w ON w.id = ici.warehouse_id SET ici.product_id = s.product_id, ici.product_name = COALESCE(p.name, ici.product_name), ici.product_category_id = s.product_category_id, ici.product_category_name = COALESCE(pc.category_name, ''''), ici.brand_category_id = s.brand_category_id, ici.brand_category_name = COALESCE(bc.category_name, ''''), ici.brand_id = s.brand_id, ici.brand_name = COALESCE(b.brand_name, ''''), ici.model = IF(ici.model = '''', s.model, ici.model), ici.warehouse_name = COALESCE(w.name, ici.warehouse_name), ici.updated_at = CURRENT_TIMESTAMP WHERE ici.product_id <> s.product_id OR ici.product_category_id <> s.product_category_id OR ici.brand_category_id <> s.brand_category_id OR ici.brand_id <> s.brand_id OR (pc.category_name IS NOT NULL AND BINARY ici.product_category_name <> BINARY pc.category_name) OR (bc.category_name IS NOT NULL AND BINARY ici.brand_category_name <> BINARY bc.category_name) OR (b.brand_name IS NOT NULL AND BINARY ici.brand_name <> BINARY b.brand_name) OR (w.name IS NOT NULL AND BINARY ici.warehouse_name <> BINARY w.name) OR (BINARY ici.model = BINARY '''' AND BINARY s.model <> BINARY '''')');

-- Number-rule records for master data objects. Product/SKU code generation still
-- uses the business naming rule in code unless the module is later switched to
-- the shared number generator.
INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('product_category', '商品分类编号', 'FL', '20060102', 4, 'active', '商品分类编码规则预置'),
('brand_category', '品牌分类编号', 'PL', '20060102', 4, 'active', '品牌分类编码规则预置'),
('brand', '品牌编号', 'PP', '20060102', 4, 'active', '品牌编码规则预置'),
('product', '商品编号', 'SP', '20060102', 4, 'active', '商品编码规则预置'),
('sku', 'SKU编号', 'SKU', '20060102', 4, 'active', 'SKU编码规则预置'),
('warehouse', '仓库编号', 'CK', '20060102', 4, 'active', '仓库编码规则预置')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);

-- Keep common operating roles able to query master data needed by linkage filters.
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'productCategory:list',
    'brandCategory:list',
    'brand:list',
    'product:list',
    'sku:list',
    'warehouse:list',
    'inventory:stock:list'
)
WHERE r.code IN (
    'super_admin',
    'boss',
    'product_admin',
    'sales',
    'sales_leader',
    'sales_manager',
    'sales_director',
    'purchase',
    'purchase_manager',
    'warehouse',
    'warehouse_manager',
    'finance',
    'auditor'
);

-- 038 creates the inventory check menu and APIs; this migration makes the
-- feature visible and usable for existing operating roles after a full import
-- or after replaying only the latest migrations.
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name IN ('inventory', 'inventoryChecks')
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = 'inventory:check:list'
WHERE r.code IN (
    'super_admin',
    'admin',
    'boss',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin',
    'auditor'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:check:create',
    'inventory:check:update',
    'inventory:check:start',
    'inventory:check:submit',
    'inventory:check:export',
    'inventory:check:print'
)
WHERE r.code IN (
    'super_admin',
    'admin',
    'warehouse',
    'warehouse_manager',
    'warehouse_staff',
    'warehouse_admin'
);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'inventory:check:delete',
    'inventory:check:audit',
    'inventory:check:reject',
    'inventory:check:adjust',
    'inventory:check:cancel'
)
WHERE r.code IN (
    'super_admin',
    'admin',
    'warehouse_manager',
    'warehouse_admin'
);

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS exec_if_table_exists;
