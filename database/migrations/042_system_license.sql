CREATE TABLE IF NOT EXISTS sys_license (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    license_no VARCHAR(100) NOT NULL COMMENT '授权编号',
    customer_name VARCHAR(200) NOT NULL COMMENT '授权客户名称',
    product_name VARCHAR(100) NOT NULL COMMENT '产品名称',
    edition VARCHAR(50) NOT NULL COMMENT '授权版本 trial/standard/professional/enterprise',
    machine_code VARCHAR(255) NOT NULL COMMENT '授权机器码',
    current_machine_code VARCHAR(255) NULL COMMENT '当前机器码',
    start_date DATE NOT NULL COMMENT '授权开始日期',
    expire_date DATE NOT NULL COMMENT '授权到期日期',
    max_users INT NOT NULL DEFAULT 0 COMMENT '最大启用用户数',
    max_orgs INT NULL COMMENT '最大机构数',
    max_warehouses INT NULL COMMENT '最大仓库数',
    modules JSON NULL COMMENT '授权模块',
    features JSON NULL COMMENT '授权功能',
    license_content JSON NOT NULL COMMENT '授权内容',
    signature TEXT NOT NULL COMMENT '授权签名',
    status VARCHAR(30) NOT NULL DEFAULT 'valid' COMMENT 'valid/expired/invalid/mismatch/not_found/disabled',
    uploaded_by BIGINT NULL COMMENT '上传人',
    uploaded_at DATETIME NULL COMMENT '上传时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_license_no (license_no),
    INDEX idx_status (status),
    INDEX idx_expire_date (expire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统授权表';

CREATE TABLE IF NOT EXISTS sys_license_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(50) NOT NULL COMMENT '操作类型 upload/verify/refresh/warning/expire',
    license_no VARCHAR(100) NULL COMMENT '授权编号',
    status VARCHAR(30) NOT NULL COMMENT 'success/failed',
    message VARCHAR(1000) NULL COMMENT '日志内容',
    operator_id BIGINT NULL COMMENT '操作人ID',
    operator_name VARCHAR(100) NULL COMMENT '操作人名称',
    ip VARCHAR(100) NULL COMMENT 'IP地址',
    user_agent VARCHAR(500) NULL COMMENT 'User-Agent',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license_no (license_no),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统授权日志表';

UPDATE menus
SET parent_id = 44,
    name = 'financeReport',
    path = 'finance',
    component = '/reports/finance/index',
    redirect = '',
    title = '财务报表',
    icon = 'Money',
    sort = 4
WHERE id = 64;

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (65, 2, 'systemLicense', 'license', '/system/license/index', '', '系统授权', 'Key', 12)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:license:view', '系统授权查看', 'api', 'system', '/api/v1/system/license/status', 'GET', 1970, 'active'),
('system:license:upload', '系统授权上传', 'api', 'system', '/api/v1/system/license/upload', 'POST', 1971, 'active'),
('system:license:refresh', '系统授权刷新', 'api', 'system', '/api/v1/system/license/refresh', 'POST', 1972, 'active'),
('system:license:logs', '系统授权日志', 'api', 'system', '/api/v1/system/license/logs', 'GET', 1973, 'active')
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
JOIN menus m ON m.name = 'systemLicense'
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('system:license:view', 'system:license:upload', 'system:license:refresh', 'system:license:logs')
WHERE r.code IN ('super_admin', 'admin', 'boss');
