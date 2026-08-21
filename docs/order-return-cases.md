# Order Return & Status Cases

## Return Reasons

| Reason            | Description                                                    | Stock Restored | Staff Commission           |
| ----------------- | -------------------------------------------------------------- | -------------- | -------------------------- |
| `CUSTOMER_CHANGE` | Customer wants to change product (different color, item, etc.) | Yes            | Deducted / Cancelled       |
| `CUSTOMER_RETURN` | Customer returns all products (doesn't want anymore)           | Yes            | Deducted / Cancelled       |
| `SIZE_CHANGE`     | Customer wants a different size                                | Yes            | Deducted / Cancelled       |
| `STORE_ERROR`     | Wrong item shipped or damaged (store's fault)                  | Yes            | Kept (staff not penalized) |

## Stock Restore Rules

Stock is restored when order status changes to:

- `CANCELLED` — order cancelled before delivery
- `RETURNED` — customer returns all products
- `PARTIALLY_RETURNED` — customer returns some products (only returned items restored)

## Commission Rules on Return

| Status | Return Reason | Commission Result |
|---|---|---|
| `RETURNED` | `STORE_ERROR` | Staff keeps commission |
| `RETURNED` | `CUSTOMER_CHANGE` / `CUSTOMER_RETURN` / `SIZE_CHANGE` | PAID → DEDUCTED, PENDING → CANCELLED |
| `PARTIALLY_RETURNED` | Any | Staff keeps commission |

## How to Track Size Change Returns

To identify orders returned due to size change:

```
GET /api/v1/orders?status=RETURNED
```

Then filter by `return_reason = SIZE_CHANGE` on the frontend, or query the DB directly:

```sql
SELECT * FROM orders
WHERE status = 'RETURNED'
  AND return_reason = 'SIZE_CHANGE'
  AND deleted_at IS NULL;
```

## Update Order Status API

```
PATCH /api/v1/orders/{uuid}/status
```

```json
{
  "status": "RETURNED",
  "return_reason": "SIZE_CHANGE",
  "note": "Customer wants size L instead of M"
}
```

Valid `status` values: `PENDING`, `CONFIRMED`, `DELIVERING`, `DELIVERED`, `CANCELLED`, `RETURNED`, `PARTIALLY_RETURNED`

Valid `return_reason` values: `CUSTOMER_CHANGE`, `STORE_ERROR`, `CUSTOMER_RETURN`, `SIZE_CHANGE`

## Partial Return API

Use this when a customer returns only some items from an order.

```
PATCH /api/v1/orders/{uuid}/partial-return
```

```json
{
  "return_reason": "SIZE_CHANGE",
  "note": "Customer keeps shoes, returns shirt and pants",
  "items": [
    { "product_uuid": "uuid-of-shirt", "quantity": 1 },
    { "product_uuid": "uuid-of-pants", "quantity": 1 }
  ]
}
```

**Rules:**

- Each `product_uuid` must exist in the original order
- `quantity` cannot exceed the ordered quantity for that product
- Order status becomes `PARTIALLY_RETURNED`
- Stock is restored only for the returned items
- Commission is deducted/cancelled (same as full return, unless `STORE_ERROR`)
