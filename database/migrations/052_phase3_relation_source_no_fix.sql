-- Phase 3 relation source number completion for invoice-linked finance documents.

UPDATE biz_relations br
JOIN receivables r ON r.id = br.source_id
SET br.source_no = r.receivable_no
WHERE br.source_type = 'receivable'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN payables p ON p.id = br.source_id
SET br.source_no = p.payable_no
WHERE br.source_type = 'payable'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN receipts r ON r.id = br.source_id
SET br.source_no = r.receipt_no
WHERE br.source_type = 'receipt'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');

UPDATE biz_relations br
JOIN payments p ON p.id = br.source_id
SET br.source_no = p.payment_no
WHERE br.source_type = 'payment'
  AND br.relation_type = 'invoice'
  AND (br.source_no IS NULL OR br.source_no = '');
