-- Fix global home route fallback so refresh does not fall back to legacy workplace.

UPDATE menus
SET redirect = '/crm/dashboard',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'dashboard'
  AND (redirect = '' OR redirect IS NULL OR redirect IN ('/dashboard/workplace', '/dashboard/workplace/index'));

UPDATE menus
SET redirect = '/crm/dashboard',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'crm'
  AND (redirect = '' OR redirect IS NULL);
