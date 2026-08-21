Phone Number Validation — Shop Phone
Add a validation rule for the customer phone number.
Reserved shop phone number: 0977156486
When the user enters 0977156486, the system should:
Detect that the phone number belongs to the shop.
Show an alert with the message:
"This is phone number of shop"
Prevent the user from continuing/submitting the customer information until the phone number is corrected.

Business reason:

0977156486 is the shop/store phone number.
If staff accidentally uses this number for a customer, the system treats the order as a delivery to the shop.
This can cause the order/delivery to remain waiting indefinitely because the actual customer never receives the delivery.

---

Implementation (google_sheet_delivery_import_service.dart):

1. Shop phone validation:
   - Reserved constant: `_shopPhoneNumber = '0977156486'`
   - After required-field checks pass, if the phone matches the shop number, the row is collected and skipped.
   - After the full loop, throws: `FormatException('This is phone number of shop in: <row labels>')`
   - Lists all affected row labels (customer name or "Row N") in the error message.

2. Phone number space stripping:
   - Phone value is normalized with `.replaceAll(' ', '')` immediately after reading from the sheet.
   - Example: `093 54 565 45` → `0935456545`
   - Ensures spaces entered in the sheet do not bypass the shop phone check or cause mismatches.
