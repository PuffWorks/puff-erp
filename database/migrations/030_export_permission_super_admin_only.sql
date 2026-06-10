-- Export is restricted to the super admin account/role only.
-- Remove all export-style permissions from non-super-admin roles.

DELETE rp
FROM role_permissions rp
JOIN permissions p ON p.id = rp.permission_id
JOIN roles r ON r.id = rp.role_id
WHERE r.code <> 'super_admin'
  AND LOWER(p.code) LIKE '%export%';
