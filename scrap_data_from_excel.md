# Plan

Build an Excel import feature that reads customer delivery data and saves it into the local Isar database.

## Excel Format

The Excel file should contain these columns:

| customerName | phone | location | price | deliver_service |
|---|---|---|---|---|
| Dara Kong | 096 333 82 689 | Phnom Penh | $15 | J&T |

## Delivery Service Options

`deliver_service` should support only:

- `J&T`
- `A`

## Flow

1. scrapes data from the Google Sheet
2. App reads each row from the Excel file.
3. For every row:
   - Validate required fields.
   - Convert the row into a customer delivery model.
   - Insert the data into Isar DB.
4. After all rows are imported successfully, show a success message.
5. Add a **Print All** button.
6. When the user clicks **Print All**:
   - Fetch all imported delivery records from Isar.
   - Print all records.

