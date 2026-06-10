DROP PROCEDURE IF EXISTS add_column_if_missing;

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

DELIMITER ;

CALL add_column_if_missing('users', 'phone', 'VARCHAR(30) NOT NULL DEFAULT '''' COMMENT ''手机号''', 'display_name');
CALL add_column_if_missing('users', 'email', 'VARCHAR(100) NOT NULL DEFAULT '''' COMMENT ''邮箱''', 'phone');
CALL add_column_if_missing('users', 'organization_id', 'BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT ''所属机构ID''', 'email');
CALL add_column_if_missing('users', 'position', 'VARCHAR(64) NOT NULL DEFAULT '''' COMMENT ''岗位''', 'organization_id');
CALL add_column_if_missing('users', 'last_login_at', 'DATETIME NULL COMMENT ''最后登录时间''', 'status');

DROP PROCEDURE IF EXISTS add_column_if_missing;

CREATE TABLE IF NOT EXISTS system_orgs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    org_name VARCHAR(100) NOT NULL,
    org_full_name VARCHAR(200) NOT NULL DEFAULT '',
    org_code VARCHAR(64) NOT NULL DEFAULT '',
    org_type VARCHAR(32) NOT NULL DEFAULT 'department',
    leader_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    phone VARCHAR(30) NOT NULL DEFAULT '',
    sort INT NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    remark VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    KEY idx_system_orgs_parent_id (parent_id),
    KEY idx_system_orgs_status (status),
    KEY idx_system_orgs_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS system_files (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL DEFAULT '',
    file_type VARCHAR(50) NOT NULL DEFAULT '',
    file_size BIGINT NOT NULL DEFAULT 0,
    content_type VARCHAR(100) NOT NULL DEFAULT '',
    storage_driver VARCHAR(32) NOT NULL DEFAULT 'local',
    business_type VARCHAR(64) NOT NULL DEFAULT '',
    business_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    business_no VARCHAR(64) NOT NULL DEFAULT '',
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    uploaded_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(500) NOT NULL DEFAULT '',
    deleted_at DATETIME NULL,
    KEY idx_system_files_name (file_name),
    KEY idx_system_files_biz (business_type, business_id),
    KEY idx_system_files_status (status),
    KEY idx_system_files_deleted_at (deleted_at)
);

CREATE TABLE IF NOT EXISTS login_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL DEFAULT '',
    user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    nickname VARCHAR(128) NOT NULL DEFAULT '',
    ip VARCHAR(64) NOT NULL DEFAULT '',
    location VARCHAR(128) NOT NULL DEFAULT '',
    browser VARCHAR(128) NOT NULL DEFAULT '',
    os VARCHAR(128) NOT NULL DEFAULT '',
    device VARCHAR(128) NOT NULL DEFAULT '',
    login_type TINYINT NOT NULL DEFAULT 0 COMMENT '0成功 1失败 2退出 3token过期',
    status VARCHAR(32) NOT NULL DEFAULT 'success',
    failure_reason VARCHAR(255) NOT NULL DEFAULT '',
    user_agent VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_login_logs_username (username),
    KEY idx_login_logs_created_at (created_at),
    KEY idx_login_logs_status (status)
);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort) VALUES
(49, 2, 'systemOrganizations', 'organization', '/system/organization/index', '', '机构管理', 'OfficeBuilding', 4),
(50, 2, 'systemFiles', 'files', '/system/file/index', '', '文件管理', 'FolderOpened', 6),
(51, 2, 'systemLoginLogs', 'login-record', '/system/login-record/index', '', '登录日志', 'Clock', 7)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
name = VALUES(name),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.id IN (49, 50, 51)
WHERE r.code IN ('super_admin', 'boss', 'auditor');

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:org:list', '机构列表', 'api', 'system', '/api/v1/system/organization', 'GET', 161, 'active'),
('system:org:create', '新增机构', 'api', 'system', '/api/v1/system/organization', 'POST', 162, 'active'),
('system:org:update', '编辑机构', 'api', 'system', '/api/v1/system/organization', 'PUT', 163, 'active'),
('system:org:delete', '删除机构', 'api', 'system', '/api/v1/system/organization/:id', 'DELETE', 164, 'active'),
('system:org:tree', '机构树', 'api', 'system', '/api/v1/system/organization/tree', 'GET', 165, 'active'),
('system:file:list', '文件列表', 'api', 'system', '/api/v1/file/page', 'GET', 171, 'active'),
('system:file:upload', '上传文件', 'api', 'system', '/api/v1/file/upload', 'POST', 172, 'active'),
('system:file:download', '下载文件', 'api', 'system', '/api/v1/file/download/:id', 'GET', 173, 'active'),
('system:file:delete', '删除文件', 'api', 'system', '/api/v1/file/remove/:id', 'DELETE', 174, 'active'),
('system:loginLog:list', '登录日志列表', 'api', 'system', '/api/v1/system/login-record/page', 'GET', 181, 'active'),
('system:loginLog:delete', '删除登录日志', 'button', 'system', '', '', 182, 'active'),
('system:loginLog:clear', '清空登录日志', 'button', 'system', '', '', 183, 'active'),
('system:loginLog:export', '导出登录日志', 'button', 'system', '', '', 184, 'active'),
('system:role:assignDataScope', '分配数据范围', 'button', 'system', '', '', 185, 'active'),
('system:menu:tree', '菜单树', 'api', 'system', '/api/v1/system/menus/tree', 'GET', 186, 'active'),
('system:user:enable', '启用用户', 'button', 'system', '', '', 187, 'active'),
('system:user:disable', '停用用户', 'button', 'system', '', '', 188, 'active'),
('system:user:assignRole', '分配用户角色', 'button', 'system', '', '', 189, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:org:list','system:org:tree','system:file:list',
    'system:loginLog:list','system:operation-log:list','system:log:list'
)
WHERE r.code IN ('boss', 'auditor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:org:list','system:org:create','system:org:update','system:org:delete','system:org:tree',
    'system:file:list','system:file:upload','system:file:download','system:file:delete',
    'system:loginLog:list','system:loginLog:delete','system:loginLog:clear','system:loginLog:export',
    'system:role:assignDataScope','system:menu:tree',
    'system:user:enable','system:user:disable','system:user:assignRole'
)
WHERE r.code = 'super_admin';

INSERT INTO system_orgs (id, parent_id, org_name, org_full_name, org_code, org_type, sort, status, remark) VALUES
(1, 0, '总公司', '总公司', 'HQ', 'company', 1, 'active', '系统默认机构'),
(2, 1, '销售部', '总公司/销售部', 'SALES', 'department', 2, 'active', ''),
(3, 1, '采购部', '总公司/采购部', 'PURCHASE', 'department', 3, 'active', ''),
(4, 1, '仓储部', '总公司/仓储部', 'WAREHOUSE', 'department', 4, 'active', ''),
(5, 1, '财务部', '总公司/财务部', 'FINANCE', 'department', 5, 'active', ''),
(6, 1, '售后部', '总公司/售后部', 'AFTERSALES', 'department', 6, 'active', '')
ON DUPLICATE KEY UPDATE
org_name = VALUES(org_name),
org_full_name = VALUES(org_full_name),
org_code = VALUES(org_code),
org_type = VALUES(org_type),
sort = VALUES(sort),
status = VALUES(status),
remark = VALUES(remark);

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:operationLog:delete', 'Delete operation logs', 'api', 'system', '/api/v1/system/operation-logs/:id', 'DELETE', 190, 'active'),
('system:operationLog:clear', 'Clear operation logs', 'api', 'system', '/api/v1/system/operation-logs/clear', 'POST', 191, 'active'),
('system:operationLog:export', 'Export operation logs', 'api', 'system', '/api/v1/system/operation-logs/export', 'GET', 192, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operationLog:delete','system:operationLog:clear','system:operationLog:export'
)
WHERE r.code = 'super_admin';
