INSERT INTO number_rules (biz_type, display_name, prefix, date_format, sequence_length, status, remark) VALUES
('customer', '客户编号', 'KH', '20060102', 4, 'active', '客户新增时自动生成编号')
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
prefix = VALUES(prefix),
date_format = VALUES(date_format),
sequence_length = VALUES(sequence_length),
status = VALUES(status),
remark = VALUES(remark);
