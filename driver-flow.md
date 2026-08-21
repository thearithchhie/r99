# Driver & Delivery Flow

## 1. Driver Management

- Admin can add, update, deactivate, and remove drivers.
- Each driver has: name, phone, status (Active / Inactive).
- Drivers are in-house staff who physically deliver orders.
- Third-party express services (e.g. VAT Express) are recorded per order via the `deliver_service` field — status tracking only, no cash settlement.

## 2. Delivery Fee (Per Order)

- The delivery fee is **variable per order** — it depends on distance.
  - Example: $1 for nearby, $2 for far away.
- The fee is set by the admin in the order detail when assigning a driver.
- Driver earnings = sum of `deliveryFee` for all their Delivered orders.
- Failed or returned orders = $0 delivery fee earned.

## 3. Cash Collection & Settlement

- On successful delivery, the driver collects the full `totalPrice` from the customer (cash on delivery).
- The driver transfers the collected amount to the shop — timing depends on the driver (immediate or end of period).
- The system tracks:
  - **Collected**: sum of `totalPrice` for all Delivered orders by this driver.
  - **Transferred**: payments the driver has recorded as paid to the shop.
  - **Outstanding**: Collected − Transferred.
- Admin records each payment via the "Record payment" field in the Drivers panel.

## 4. Staff Commission

- Chat staff (Facebook responders) earn **$0.50 per successful (Delivered) delivery**.
- Failed, returned, or pending orders = $0 commission for that order.
- Commission is calculated automatically from stored delivery orders.
- Payroll uses "Count from Deliveries" to fill weekly totals from Delivered orders only.

## 5. Reporting

- **Staff Commission Report**: delivered / failed count and total commission per staff member.
- **Driver Settlement Report**: collected / transferred / outstanding / delivery fees earned per driver.
- **Delivery KPIs**: total orders, delivered, failed, revenue collected.
- All reports are on the Reports page under "Delivery Reports".
