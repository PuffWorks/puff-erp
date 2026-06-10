-- Ensure order contact snapshots never keep frontend-masked values.
UPDATE quotations q
JOIN customers c ON c.id = q.customer_id
SET
    q.contact_name = CASE WHEN TRIM(q.contact_name) = '' OR q.contact_name = '***' THEN c.contact_name ELSE q.contact_name END,
    q.contact_phone = CASE WHEN TRIM(q.contact_phone) = '' OR q.contact_phone = '***' THEN c.contact_phone ELSE q.contact_phone END
WHERE TRIM(q.contact_name) = ''
   OR q.contact_name = '***'
   OR TRIM(q.contact_phone) = ''
   OR q.contact_phone = '***';

UPDATE sales_orders so
JOIN customers c ON c.id = so.customer_id
SET
    so.contact_name = CASE WHEN TRIM(so.contact_name) = '' OR so.contact_name = '***' THEN c.contact_name ELSE so.contact_name END,
    so.contact_phone = CASE WHEN TRIM(so.contact_phone) = '' OR so.contact_phone = '***' THEN c.contact_phone ELSE so.contact_phone END
WHERE TRIM(so.contact_name) = ''
   OR so.contact_name = '***'
   OR TRIM(so.contact_phone) = ''
   OR so.contact_phone = '***';
