-- Fix legacy frontend menu component paths that can fall through to Vue 404.

UPDATE menus
SET component = '/crm/customers/index',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'customers'
  AND component = '/customer/index';
