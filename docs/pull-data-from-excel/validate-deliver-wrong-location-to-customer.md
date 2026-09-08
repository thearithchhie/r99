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

Process:

1. Shop phone validation:
   - During import, each row's phone number is checked against the reserved shop number 0977156486.
   - If a match is found, that row is skipped and collected.
   - After all rows are processed, the import fails with an error listing every row that used the shop number.

2. Phone number space stripping:
   - Before any validation, all spaces are removed from the phone number.
   - Example: 093 54 565 45 becomes 0935456545.
   - This prevents staff from accidentally bypassing the shop phone check by adding spaces.

---

Total Price — Zero-Price Statuses

When a row's status indicates the order has already been paid, the imported price is set to $0 regardless of what is written in the total price column.

Statuses that set price to $0:
- ALRADY_PAID — customer already paid
- PAID_BY_SHOP — shop covered the payment
