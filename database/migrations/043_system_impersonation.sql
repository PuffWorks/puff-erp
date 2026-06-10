CREATE TABLE IF NOT EXISTS sys_impersonation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_user_id BIGINT NOT NULL COMMENT '原始操作人ID',
    original_username VARCHAR(100) NOT NULL COMMENT '原始操作人账号',
    target_user_id BIGINT NOT NULL COMMENT '被代登录用户ID',
    target_username VARCHAR(100) NOT NULL COMMENT '被代登录用户账号',
    reason VARCHAR(500) NOT NULL COMMENT '代登录原因',
    mode VARCHAR(30) NOT NULL DEFAULT 'readonly' COMMENT 'readonly/operation',
    login_ip VARCHAR(100) NULL COMMENT 'IP地址',
    user_agent VARCHAR(500) NULL COMMENT '浏览器信息',
    started_at DATETIME NOT NULL COMMENT '开始时间',
    ended_at DATETIME NULL COMMENT '结束时间',
    status VARCHAR(30) NOT NULL DEFAULT 'active' COMMENT 'active/exited/expired',
    created_at DATETIME NOT NULL,
    INDEX idx_original_user_id (original_user_id),
    INDEX idx_target_user_id (target_user_id),
    INDEX idx_started_at (started_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代登录日志表';

INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status)
VALUES
('system:user:impersonate', '代登录用户', 'api', 'system', '/api/v1/system/users/:id/impersonate', 'POST', 108, 'active'),
('system:user:impersonateSubordinate', '代登录下级用户', 'api', 'system', '/api/v1/system/users/:id/impersonate-subordinate', 'POST', 109, 'active'),
('system:user:viewSubordinate', '查看下级用户', 'api', 'system', '/api/v1/system/users/subordinates', 'GET', 110, 'active'),
('system:user:impersonateLog', '代登录日志', 'api', 'system', '/api/v1/system/impersonation-logs', 'GET', 111, 'active')
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
    'system:user:impersonate',
    'system:user:impersonateSubordinate',
    'system:user:viewSubordinate',
    'system:user:impersonateLog'
)
WHERE r.code IN ('super_admin', 'admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:user:impersonateSubordinate',
    'system:user:viewSubordinate'
)
WHERE r.code IN ('sales_manager', 'sales_leader', 'department_leader', 'team_leader');
