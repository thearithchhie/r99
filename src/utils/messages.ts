/**
 * Centralised UI strings.
 * All user-facing messages live here so translation is a single-file change.
 *
 * Usage:
 *   import { MSG } from '@/utils/messages'
 *   <FieldError :message="MSG.val.selectCustomer" />
 *   openDialog({ message: MSG.err.generic })
 */

export const MSG = {

  /** Validation — shown inline under form fields */
  val: {
    // Generic
    nameRequired:       'Name is required',
    nameTooLong:        'Name must be 100 chars or less',
    phoneRequired:      'Phone is required',
    passwordRequired:   'Password is required',
    facebookRequired:   'Facebook name is required',
    priceRequired:      'Price is required',
    dateRequired:       'Date is required',
    amountRequired:     'Amount is required',
    amountMin:          'Amount must be greater than 0',
    categoryRequired:   'Category is required',
    roleNameRequired:   'Role name is required',

    // Product / Model
    productNameRequired: 'Product name is required',
    sizeRequired:        'Size is required',
    colorRequired:       'Color is required',

    // Order
    selectCustomer:    'Please select a customer.',
    selectStaff:       'Please select a staff member.',
    selectProduct:     'Please select a product.',
    selectVariant:     'Please select a variant.',
    selectOrder:       'Please select an order.',
    addItem:           'Please add at least one item.',
    selectReturnItem:  'Please select at least one item to return.',
    deliveryAddress:   'Delivery address is required.',
    deliveryCost:      'Please enter a valid delivery cost (min 0).',

    // Purchase
    selectSupplier:    'Supplier is required',
    purchaseAddItem:   'At least one item is required',
    itemNeedsProduct:  'All items must have a product selected',

    // Payroll
    weekStartRequired: 'Week start date is required.',
    weekEndRequired:   'Week end date is required.',
  },

  /** Error dialogs — shown in AppDialog on API failure */
  err: {
    generic:           'Something went wrong. Please try again.',
    createOrder:       'Failed to create order.',
    missingInfo:       'Please fill in all required fields before continuing.',
  },

} as const
