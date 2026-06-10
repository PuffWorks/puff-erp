-- Backfill historical business relations for phase 3 evidence chain.

CREATE TABLE IF NOT EXISTS biz_relations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    source_type VARCHAR(64) NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    source_no VARCHAR(64) NOT NULL DEFAULT '',
    target_type VARCHAR(64) NOT NULL,
    target_id BIGINT UNSIGNED NOT NULL,
    target_no VARCHAR(64) NOT NULL DEFAULT '',
    relation_type VARCHAR(64) NOT NULL DEFAULT '',
    created_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_biz_rel_source (source_type, source_id),
    KEY idx_biz_rel_target (target_type, target_id),
    KEY idx_biz_rel_relation_type (relation_type)
);

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'quotation', q.id, q.quotation_no, 'sales_order', so.id, so.sales_order_no, 'convert', COALESCE(so.created_by, q.created_by, 0), COALESCE(so.created_at, q.updated_at, NOW())
FROM sales_orders so
JOIN quotations q ON q.id = so.source_quotation_id AND q.deleted_at IS NULL
WHERE so.deleted_at IS NULL AND so.source_quotation_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='quotation' AND br.source_id=q.id AND br.target_type='sales_order' AND br.target_id=so.id AND br.relation_type='convert');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'purchase_order', po.id, po.purchase_order_no, 'purchase', COALESCE(po.created_by, so.created_by, 0), COALESCE(po.created_at, NOW())
FROM purchase_orders po
JOIN sales_orders so ON so.id = po.source_sales_order_id AND so.deleted_at IS NULL
WHERE po.deleted_at IS NULL AND po.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='purchase_order' AND br.target_id=po.id AND br.relation_type='purchase');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'outbound_order', oo.id, oo.outbound_order_no, 'outbound', COALESCE(oo.created_by, so.created_by, 0), COALESCE(oo.created_at, NOW())
FROM inventory_outbound_orders oo
JOIN sales_orders so ON so.id = oo.source_sales_order_id AND so.deleted_at IS NULL
WHERE oo.deleted_at IS NULL AND oo.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='outbound_order' AND br.target_id=oo.id AND br.relation_type='outbound');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'receivable', r.id, r.receivable_no, 'receivable', COALESCE(r.created_by, so.created_by, 0), COALESCE(r.created_at, NOW())
FROM receivables r
JOIN sales_orders so ON so.id = r.sales_order_id AND so.deleted_at IS NULL
WHERE r.deleted_at IS NULL AND r.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='receivable' AND br.target_id=r.id AND br.relation_type='receivable');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'receipt', rp.id, rp.receipt_no, 'receipt', COALESCE(rp.created_by, so.created_by, 0), COALESCE(rp.created_at, NOW())
FROM receipts rp
JOIN sales_orders so ON so.id = rp.sales_order_id AND so.deleted_at IS NULL
WHERE rp.deleted_at IS NULL AND rp.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='receipt' AND br.target_id=rp.id AND br.relation_type='receipt');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, so.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN sales_orders so ON so.id = i.source_id AND i.source_type = 'sales_order' AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, r.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receivables r ON r.id = i.receivable_id AND r.deleted_at IS NULL
JOIN sales_orders so ON so.id = r.sales_order_id AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, rp.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receipts rp ON rp.id = i.receipt_id AND rp.deleted_at IS NULL
JOIN sales_orders so ON so.id = rp.sales_order_id AND so.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'sales' AND i.receipt_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'contract', c.id, c.contract_no, 'contract', COALESCE(c.created_by, so.created_by, 0), COALESCE(c.created_at, NOW())
FROM contracts c
JOIN sales_orders so ON so.id = c.sales_order_id AND so.deleted_at IS NULL
WHERE c.deleted_at IS NULL AND c.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='contract' AND br.target_id=c.id AND br.relation_type='contract');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'aftersales', a.id, a.ticket_no, 'aftersales', COALESCE(a.created_by, so.created_by, 0), COALESCE(a.created_at, NOW())
FROM aftersales a
JOIN sales_orders so ON so.id = a.sales_order_id AND so.deleted_at IS NULL
WHERE a.deleted_at IS NULL AND a.sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='aftersales' AND br.target_id=a.id AND br.relation_type='aftersales');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'sales_order', so.id, so.sales_order_no, 'sales_return', sr.id, sr.return_no, 'return', COALESCE(sr.created_by, so.created_by, 0), COALESCE(sr.created_at, NOW())
FROM inventory_sales_return_orders sr
JOIN sales_orders so ON so.id = sr.source_sales_order_id AND so.deleted_at IS NULL
WHERE sr.deleted_at IS NULL AND sr.source_sales_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='sales_order' AND br.source_id=so.id AND br.target_type='sales_return' AND br.target_id=sr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'outbound_order', oo.id, oo.outbound_order_no, 'sales_return', sr.id, sr.return_no, 'return', COALESCE(sr.created_by, oo.created_by, 0), COALESCE(sr.created_at, NOW())
FROM inventory_sales_return_orders sr
JOIN inventory_outbound_orders oo ON oo.id = sr.source_outbound_order_id AND oo.deleted_at IS NULL
WHERE sr.deleted_at IS NULL AND sr.source_outbound_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='outbound_order' AND br.source_id=oo.id AND br.target_type='sales_return' AND br.target_id=sr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'inbound_order', io.id, io.inbound_order_no, 'inbound', COALESCE(io.created_by, po.created_by, 0), COALESCE(io.created_at, NOW())
FROM inventory_inbound_orders io
JOIN purchase_orders po ON po.id = io.source_purchase_order_id AND po.deleted_at IS NULL
WHERE io.deleted_at IS NULL AND io.source_purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='inbound_order' AND br.target_id=io.id AND br.relation_type='inbound');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'payable', p.id, p.payable_no, 'payable', COALESCE(p.created_by, po.created_by, 0), COALESCE(p.created_at, NOW())
FROM payables p
JOIN purchase_orders po ON po.id = p.purchase_order_id AND po.deleted_at IS NULL
WHERE p.deleted_at IS NULL AND p.purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='payable' AND br.target_id=p.id AND br.relation_type='payable');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'payment', pm.id, pm.payment_no, 'payment', COALESCE(pm.created_by, po.created_by, 0), COALESCE(pm.created_at, NOW())
FROM payments pm
JOIN purchase_orders po ON po.id = pm.purchase_order_id AND po.deleted_at IS NULL
WHERE pm.deleted_at IS NULL AND pm.purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='payment' AND br.target_id=pm.id AND br.relation_type='payment');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, po.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN purchase_orders po ON po.id = i.source_id AND i.source_type = 'purchase_order' AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, p.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payables p ON p.id = i.payable_id AND p.deleted_at IS NULL
JOIN purchase_orders po ON po.id = p.purchase_order_id AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, pm.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payments pm ON pm.id = i.payment_id AND pm.deleted_at IS NULL
JOIN purchase_orders po ON po.id = pm.purchase_order_id AND po.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.invoice_type = 'purchase' AND i.payment_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'purchase_order', po.id, po.purchase_order_no, 'purchase_return', pr.id, pr.return_no, 'return', COALESCE(pr.created_by, po.created_by, 0), COALESCE(pr.created_at, NOW())
FROM inventory_purchase_return_orders pr
JOIN purchase_orders po ON po.id = pr.source_purchase_order_id AND po.deleted_at IS NULL
WHERE pr.deleted_at IS NULL AND pr.source_purchase_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='purchase_order' AND br.source_id=po.id AND br.target_type='purchase_return' AND br.target_id=pr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'inbound_order', io.id, io.inbound_order_no, 'purchase_return', pr.id, pr.return_no, 'return', COALESCE(pr.created_by, io.created_by, 0), COALESCE(pr.created_at, NOW())
FROM inventory_purchase_return_orders pr
JOIN inventory_inbound_orders io ON io.id = pr.source_inbound_order_id AND io.deleted_at IS NULL
WHERE pr.deleted_at IS NULL AND pr.source_inbound_order_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='inbound_order' AND br.source_id=io.id AND br.target_type='purchase_return' AND br.target_id=pr.id AND br.relation_type='return');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT i.source_type, i.source_id, i.source_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
WHERE i.deleted_at IS NULL AND i.source_type <> '' AND i.source_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type=i.source_type AND br.source_id=i.source_id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receivable', r.id, r.receivable_no, 'receipt', rp.id, rp.receipt_no, 'receipt', COALESCE(rp.created_by, r.created_by, 0), COALESCE(rp.created_at, NOW())
FROM receipts rp
JOIN receivables r ON r.id = rp.receivable_id AND r.deleted_at IS NULL
WHERE rp.deleted_at IS NULL AND rp.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receivable' AND br.source_id=r.id AND br.target_type='receipt' AND br.target_id=rp.id AND br.relation_type='receipt');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payable', p.id, p.payable_no, 'payment', pm.id, pm.payment_no, 'payment', COALESCE(pm.created_by, p.created_by, 0), COALESCE(pm.created_at, NOW())
FROM payments pm
JOIN payables p ON p.id = pm.payable_id AND p.deleted_at IS NULL
WHERE pm.deleted_at IS NULL AND pm.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payable' AND br.source_id=p.id AND br.target_type='payment' AND br.target_id=pm.id AND br.relation_type='payment');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receivable', r.id, r.receivable_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, r.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receivables r ON r.id = i.receivable_id AND r.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.receivable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receivable' AND br.source_id=r.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payable', p.id, p.payable_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, p.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payables p ON p.id = i.payable_id AND p.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.payable_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payable' AND br.source_id=p.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'receipt', rp.id, rp.receipt_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, rp.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN receipts rp ON rp.id = i.receipt_id AND rp.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.receipt_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='receipt' AND br.source_id=rp.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT 'payment', pm.id, pm.payment_no, 'finance_invoice', i.id, i.invoice_no, 'invoice', COALESCE(i.created_by, pm.created_by, 0), COALESCE(i.created_at, NOW())
FROM finance_invoices i
JOIN payments pm ON pm.id = i.payment_id AND pm.deleted_at IS NULL
WHERE i.deleted_at IS NULL AND i.payment_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type='payment' AND br.source_id=pm.id AND br.target_type='finance_invoice' AND br.target_id=i.id AND br.relation_type='invoice');

INSERT INTO biz_relations (source_type, source_id, source_no, target_type, target_id, target_no, relation_type, created_by, created_at)
SELECT e.biz_type, e.biz_id, e.biz_no, 'finance_expense', e.id, e.expense_no, 'expense', COALESCE(e.created_by, 0), COALESCE(e.created_at, NOW())
FROM finance_expense_orders e
WHERE e.deleted_at IS NULL AND e.biz_type <> '' AND e.biz_id > 0
  AND NOT EXISTS (SELECT 1 FROM biz_relations br WHERE br.source_type=e.biz_type AND br.source_id=e.biz_id AND br.target_type='finance_expense' AND br.target_id=e.id AND br.relation_type='expense');
