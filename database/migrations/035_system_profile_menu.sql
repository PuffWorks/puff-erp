INSERT INTO menus (id, parent_id, name, path, component, redirect, title, icon, sort)
VALUES (61, 2, 'systemProfile', 'profile', '/user/profile/index', '', '个人设置', 'User', 10)
ON DUPLICATE KEY UPDATE
parent_id = VALUES(parent_id),
path = VALUES(path),
component = VALUES(component),
redirect = VALUES(redirect),
title = VALUES(title),
icon = VALUES(icon),
sort = VALUES(sort);

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'system'
WHERE r.status = 'active';

INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM roles r
JOIN menus m ON m.name = 'systemProfile'
WHERE r.status = 'active';
