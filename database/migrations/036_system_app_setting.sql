CREATE TABLE IF NOT EXISTS system_app_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  project_name VARCHAR(128) NOT NULL DEFAULT '',
  logo_url MEDIUMTEXT NULL,
  updated_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统外观设置';

INSERT INTO system_app_settings (id, project_name, logo_url, updated_by)
VALUES (1, '圣泰安科技', '', 0)
ON DUPLICATE KEY UPDATE
project_name = IF(project_name = '', VALUES(project_name), project_name);

INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (63, 2, 'systemAppSetting', 'app-setting', '/system/app-setting/index', '', '系统外观', 'Brush', 10)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

UPDATE menus SET sort = 11 WHERE name = 'systemProfile';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:app-setting:view', '系统外观查看', 'api', 'system', '/api/v1/system/app-setting', 'GET', 1960, 'active'),
('system:app-setting:update', '系统外观保存', 'api', 'system', '/api/v1/system/app-setting', 'PUT', 1961, 'active')
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
JOIN menus m ON m.name = 'systemAppSetting'
WHERE r.code IN ('super_admin', 'admin', 'boss');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('system:app-setting:view', 'system:app-setting:update')
WHERE r.code IN ('super_admin', 'admin', 'boss');
