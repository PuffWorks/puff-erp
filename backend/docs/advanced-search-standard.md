# Advanced Search Standard

## Goal

All list and report pages should expose advanced search only for fields that are actually supported by the backend query API.

## Common Query Fields

- `keyword`: fuzzy search for document number, name, customer, supplier, SKU, SN, or contact.
- `status`: business status.
- `start_date`, `end_date`: primary business date range.
- `customer_id`, `supplier_id`, `warehouse_id`, `project_id`: master data filters.
- `owner_id`, `owner_org_id`, `created_by`: ownership and creator filters.
- `min_amount`, `max_amount`: amount range.
- `sales_order_id`, `purchase_order_id`, `contract_id`, `ticket_id`: related document filters.
- `source_type`, `source_id`: source document filters.

## Frontend Rules

- `ErpDataPage` pages use `advanced-search` and `#advanced-search`.
- `MasterDataCrudPage` pages use `searchFields`.
- `ErpReportPage` pages use `advanced-search` and `#advanced-search`.
- Basic search keeps keyword, status, and the most common date filter.
- Low-frequency and relational filters belong in advanced search.
- UI-only range fields should use names ending in `_range`; they are not sent to backend directly.

## Backend Rules

- Every visible advanced field must have a matching DTO `form` tag.
- Repository/service code must apply the corresponding filter.
- Export endpoints must reuse the same query filter contract.
- Unsupported fields should not be shown in the UI.

## Verification

- Frontend: `npm run typecheck && npm run build`.
- Backend: `go test ./...`.
- Manual: expand advanced search, search, reset, refresh, route query restore, and export with filters.
