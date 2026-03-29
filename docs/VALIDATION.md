# Validation Guide

This API uses **go-playground/validator/v10** for request validation.

## Overview

All POST and PUT endpoints validate incoming requests before processing. Invalid requests return a `400 Bad Request` status with detailed error messages.

## Validation Rules

### Common Validators

| Tag | Description | Example |
|-----|-------------|---------|
| `required` | Field must be present and non-zero | `validate:"required"` |
| `email` | Must be a valid email address | `validate:"email"` |
| `min` | Minimum value (string length or number) | `validate:"min=3"` |
| `max` | Maximum value (string length or number) | `validate:"max=255"` |
| `gt` | Greater than (numbers) | `validate:"gt=0"` |
| `gte` | Greater than or equal to | `validate:"gte=0"` |
| `lt` | Less than (numbers) | `validate:"lt=100"` |
| `lte` | Less than or equal to | `validate:"lte=100"` |
| `oneof` | Must be one of the specified values | `validate:"oneof=cash card credit"` |
| `omitempty` | Skip validation if field is empty | `validate:"omitempty,max=255"` |
| `dive` | Validate array/slice elements | `validate:"dive,required"` |

## Module-Specific Validation

### Customer Module

**CreateCustomerRequest:**
```json
{
  "name": "John Doe",           // required, 2-255 characters
  "email": "john@example.com",  // required, valid email, max 255
  "phone": "+1234567890",       // required, 10-50 characters
  "address": "123 Main St",     // optional, max 500
  "city": "New York",           // optional, max 100
  "country": "USA",             // optional, max 100
  "postal_code": "10001"        // optional, max 20
}
```

### Product Module

**CreateProductRequest:**
```json
{
  "name": "Product Name",       // required, 2-255 characters
  "description": "Description", // optional, max 2000
  "sku": "PROD-001",            // required, 3-100 characters
  "price": 29.99,               // required, greater than 0
  "cost": 15.00,                // optional, greater than or equal to 0
  "quantity": 100,              // optional, greater than or equal to 0
  "category_id": 1              // optional, valid ID
}
```

### Inventory Module

**CreateInventoryRequest:**
```json
{
  "product_id": 1,              // required, valid ID
  "quantity": 50,               // optional, greater than or equal to 0
  "reorder_level": 10,          // optional, greater than or equal to 0
  "reorder_quantity": 50,       // optional, greater than or equal to 0
  "location": "Warehouse A"     // optional, max 100
}
```

**AddStockRequest:**
```json
{
  "quantity": 25,               // required, greater than 0
  "reference": "PO-123",        // optional, max 255
  "notes": "Restock"            // optional, max 1000
}
```

### Sale Module

**CreateSaleRequest:**
```json
{
  "customer_id": 1,             // optional, valid ID
  "payment_method": "card",     // required, must be: cash, card, credit, transfer
  "items": [                    // required, at least 1 item
    {
      "product_id": 1,          // required, valid ID
      "quantity": 2,            // required, greater than 0
      "discount": 0             // optional, greater than or equal to 0
    }
  ],
  "discount": 0,                // optional, greater than or equal to 0
  "tax_rate": 0.1,              // optional, 0.0 to 1.0 (10% = 0.1)
  "notes": "Customer notes"     // optional, max 1000
}
```

**UpdateSaleRequest:**
```json
{
  "payment_status": "paid",     // optional, must be: pending, paid, failed, refunded
  "status": "completed"         // optional, must be: pending, completed, cancelled
}
```

## Error Responses

### Validation Error Format

```json
{
  "error": "validation failed: email must be a valid email, phone is required, name must be at least 2 characters"
}
```

### Example Errors

**Missing Required Field:**
```bash
POST /api/customers
{
  "email": "invalid-email"
}

Response: 400 Bad Request
{
  "error": "validation failed: name is required, phone is required, email must be a valid email"
}
```

**Invalid Value Range:**
```bash
POST /api/products
{
  "name": "P",
  "sku": "ABC",
  "price": -10
}

Response: 400 Bad Request
{
  "error": "validation failed: name must be at least 2, price must be greater than 0"
}
```

**Invalid Payment Method:**
```bash
POST /api/sales
{
  "payment_method": "bitcoin",
  "items": [{"product_id": 1, "quantity": 1}]
}

Response: 400 Bad Request
{
  "error": "validation failed: payment_method must be one of: cash card credit transfer"
}
```

## Testing Validation

### Using curl

```bash
# Valid request
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  }'

# Invalid request (will return validation errors)
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "J",
    "email": "invalid",
    "phone": "123"
  }'
```

## Custom Validation

To add custom validation rules:

1. Add the validator tag to your struct
2. The validator package will automatically format error messages
3. Error messages use the JSON tag name for better readability

Example:
```go
type CreateProductRequest struct {
    SKU string `json:"sku" validate:"required,min=3,max=100"`
}
```

This will validate that SKU is:
- Required
- At least 3 characters
- At most 100 characters

Error message: `"sku is required"` or `"sku must be at least 3"`