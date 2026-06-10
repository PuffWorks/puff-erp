-- Deprecate legacy customer management write permissions after CRM takeover.
-- Keep customer:list as a foundational read permission for shared selectors.

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
WHERE p.code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
);

UPDATE permissions
SET status = 'disabled'
WHERE code IN (
    'customer:create',
    'customer:update',
    'customer:delete',
    'customer:transfer',
    'customer:assignOwner',
    'customer:enable',
    'customer:disable',
    'customer:export',
    'customer:import',
    'customer:log'
);
