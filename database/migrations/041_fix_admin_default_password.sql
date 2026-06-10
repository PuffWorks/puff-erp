-- Fix the default admin password hash.
-- The previous seed hash does not match the documented default password:
-- username: admin
-- password: admin123

UPDATE users
SET password_hash = '$2a$10$yOcqosM6UTLC1GWy0lM/9.R742LAQkGzK26MSI3ICK/QRXhzZ3y36',
    status = 'active',
    deleted_at = NULL
WHERE username = 'admin'
  AND password_hash = '$2a$10$cHJ9BT8U1pqavd4LAMREA.enboTE.v/PebsWwad3Z5GEgFIfenp7i';
