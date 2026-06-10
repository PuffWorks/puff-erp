# API Notes

Base path: `/api/v1`

## Health

- `GET /healthz`

## Auth

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/profile`
- `GET /api/v1/auth/menus`
- `GET /api/v1/auth/permissions`

## System Management

- `GET /api/v1/system/users`
- `POST /api/v1/system/users`
- `PUT /api/v1/system/users/{id}`
- `DELETE /api/v1/system/users/{id}`
- `GET /api/v1/system/roles`
- `POST /api/v1/system/roles`
- `PUT /api/v1/system/roles/{id}`
- `DELETE /api/v1/system/roles/{id}`
- `GET /api/v1/system/permissions`
- `GET /api/v1/system/menus`
- `POST /api/v1/system/menus`
- `PUT /api/v1/system/menus/{id}`
- `DELETE /api/v1/system/menus/{id}`
- `GET /api/v1/system/dicts`
- `POST /api/v1/system/dicts`
- `PUT /api/v1/system/dicts/{id}`
- `DELETE /api/v1/system/dicts/{id}`
- `POST /api/v1/system/dicts/{id}/items`
- `PUT /api/v1/system/dict-items/{itemId}`
- `DELETE /api/v1/system/dict-items/{itemId}`
- `GET /api/v1/system/number-rules`
- `POST /api/v1/system/number-rules`
- `PUT /api/v1/system/number-rules/{id}`
- `DELETE /api/v1/system/number-rules/{id}`
- `GET /api/v1/system/operation-logs`

## Reports

- `GET /api/v1/reports/sales`
- `GET /api/v1/reports/purchase`
- `GET /api/v1/reports/inventory`
- `GET /api/v1/reports/aftersales`

## Sales Outbound Request Example

When an item requires SN management, the frontend must bind SN codes by `line_no`, not only by `sku_id`.

```json
{
  "warehouse_id": 1,
  "remark": "outbound by sales order",
  "items": [
    {
      "line_no": 1,
      "sn_codes": ["SN20260001", "SN20260002"]
    },
    {
      "line_no": 2,
      "sn_codes": []
    }
  ]
}
```

Endpoint:

- `POST /api/v1/sales-orders/{id}/create-outbound`

## Purchase Inbound Request Example

```json
{
  "remark": "inbound from supplier",
  "items": [
    {
      "line_no": 1,
      "sn_codes": ["SNIN20260001", "SNIN20260002"]
    }
  ]
}
```

Endpoint:

- `POST /api/v1/purchase-orders/{id}/create-inbound`

## Sales Update Request Example

```json
{
  "contact_name": "Alice",
  "contact_phone": "13800000000",
  "remark": "customer revised quantity",
  "items": [
    {
      "line_no": 1,
      "sku_id": 12,
      "quantity": "2",
      "unit": "pcs",
      "unit_price": "1280.0000",
      "discount_rate": "1.0000",
      "tax_rate": "0.1300",
      "remark": ""
    }
  ]
}
```

Endpoint:

- `PUT /api/v1/sales-orders/{id}`

## Purchase Update Request Example

```json
{
  "contact_name": "Bob",
  "contact_phone": "13900000000",
  "currency": "CNY",
  "tax_rate": "0.1300",
  "remark": "supplier updated",
  "items": [
    {
      "line_no": 1,
      "sku_id": 12,
      "quantity": "5",
      "unit": "pcs",
      "unit_price": "900.0000",
      "tax_rate": "0.1300",
      "remark": ""
    }
  ]
}
```

Endpoint:

- `PUT /api/v1/purchase-orders/{id}`

## SN Validation Failure Examples

SN-enabled SKU without SN codes:

```json
{
  "code": 80003,
  "message": "sn codes are required for sku outbound",
  "data": null,
  "request_id": "req_xxx"
}
```

Duplicate SN in the same request:

```json
{
  "code": 80004,
  "message": "duplicate sn code in outbound request: SN20260001",
  "data": null,
  "request_id": "req_xxx"
}
```

SN count does not match quantity:

```json
{
  "code": 80005,
  "message": "sn count does not match outbound quantity",
  "data": null,
  "request_id": "req_xxx"
}
```

## Workflow Endpoints Added

- `PUT /api/v1/sales-orders/{id}`
- `POST /api/v1/sales-orders/{id}/resubmit`
- `POST /api/v1/sales-orders/{id}/cancel`
- `POST /api/v1/sales-orders/{id}/create-outbound`
- `PUT /api/v1/purchase-orders/{id}`
- `POST /api/v1/purchase-orders/{id}/resubmit`
- `POST /api/v1/purchase-orders/{id}/cancel`
- `POST /api/v1/purchase-orders/{id}/create-inbound`
- `GET /api/v1/inventory/inbound-orders`
- `GET /api/v1/inventory/inbound-orders/{id}`
- `GET /api/v1/inventory/outbound-orders`
- `GET /api/v1/inventory/outbound-orders/{id}`
- `GET /api/v1/finance/receivables`
- `GET /api/v1/finance/payables`
- `GET /api/v1/finance/receipts`
- `GET /api/v1/finance/payments`
- `POST /api/v1/finance/receipts`
- `POST /api/v1/finance/payments`
- `POST /api/v1/finance/writeoffs/reverse`
- `GET /api/v1/system/dicts`
- `GET /api/v1/system/number-rules`
