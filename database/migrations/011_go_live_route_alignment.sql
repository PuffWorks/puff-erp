INSERT INTO permissions (code, name, permission_type, module, path, method, sort, status) VALUES
('system:operationLog:detail', '操作日志详情', 'api', 'system', '/api/v1/system/operation-logs/:id', 'GET', 193, 'active'),
('system:role:enable', '启用角色', 'api', 'system', '/api/v1/system/roles/:id/enable', 'POST', 194, 'active'),
('system:role:disable', '停用角色', 'api', 'system', '/api/v1/system/roles/:id/disable', 'POST', 195, 'active')
ON DUPLICATE KEY UPDATE
name = VALUES(name),
permission_type = VALUES(permission_type),
module = VALUES(module),
path = VALUES(path),
method = VALUES(method),
sort = VALUES(sort),
status = VALUES(status);

UPDATE permissions SET path = '/api/v1/system/roles/:id/assign-permissions', method = 'POST'
WHERE code = 'system:role:assignPermission';

UPDATE permissions SET path = '/api/v1/system/roles/:id/assign-data-scope', method = 'POST'
WHERE code = 'system:role:assignDataScope';

UPDATE permissions SET path = '/api/v1/system/orgs', method = 'GET'
WHERE code = 'system:org:list';

UPDATE permissions SET path = '/api/v1/system/orgs', method = 'POST'
WHERE code = 'system:org:create';

UPDATE permissions SET path = '/api/v1/system/orgs/:id', method = 'PUT'
WHERE code = 'system:org:update';

UPDATE permissions SET path = '/api/v1/system/orgs/:id', method = 'DELETE'
WHERE code = 'system:org:delete';

UPDATE permissions SET path = '/api/v1/system/orgs/tree', method = 'GET'
WHERE code = 'system:org:tree';

UPDATE permissions SET path = '/api/v1/system/files', method = 'GET'
WHERE code = 'system:file:list';

UPDATE permissions SET path = '/api/v1/system/files/upload', method = 'POST'
WHERE code = 'system:file:upload';

UPDATE permissions SET path = '/api/v1/system/files/:id/download', method = 'GET'
WHERE code = 'system:file:download';

UPDATE permissions SET path = '/api/v1/system/files/:id', method = 'DELETE'
WHERE code = 'system:file:delete';

UPDATE permissions SET path = '/api/v1/system/login-logs', method = 'GET'
WHERE code = 'system:loginLog:list';

UPDATE permissions SET path = '/api/v1/system/login-logs/:id', method = 'DELETE'
WHERE code = 'system:loginLog:delete';

UPDATE permissions SET path = '/api/v1/system/login-logs/clear', method = 'POST'
WHERE code = 'system:loginLog:clear';

UPDATE permissions SET path = '/api/v1/system/login-logs/export', method = 'GET'
WHERE code = 'system:loginLog:export';

UPDATE permissions SET path = '/api/v1/system/dict-types', method = 'GET'
WHERE code = 'system:dict:list';

UPDATE permissions SET path = '/api/v1/system/dict-types', method = 'POST'
WHERE code = 'system:dict:create';

UPDATE permissions SET path = '/api/v1/system/dict-types/:id', method = 'PUT'
WHERE code = 'system:dict:update';

UPDATE permissions SET path = '/api/v1/system/dict-types/:id', method = 'DELETE'
WHERE code = 'system:dict:delete';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/check-stock', method = 'POST'
WHERE code = 'sales:checkStock';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/generate-purchase', method = 'POST'
WHERE code = 'sales:generatePurchase';

UPDATE permissions SET path = '/api/v1/sales-orders/:id/outbound', method = 'POST'
WHERE code = 'sales:outbound';

UPDATE permissions SET path = '/api/v1/purchase-orders/:id/inbound', method = 'POST'
WHERE code = 'purchase:inbound';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
    'system:operationLog:detail',
    'system:role:enable',
    'system:role:disable'
)
WHERE r.code IN ('super_admin', 'admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN (
    'system:operationLog:detail',
    'system:role:enable',
    'system:role:disable'
);
