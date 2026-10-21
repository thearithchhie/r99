-- Seed CRUD permissions for all modules
INSERT INTO permissions (name, description, module, action, status) VALUES
-- USER
('CREATE_USER',             'Create a new user',               'USER',             'create', 'ACTIVE'),
('READ_USER',               'View users',                      'USER',             'read',   'ACTIVE'),
('UPDATE_USER',             'Update a user',                   'USER',             'update', 'ACTIVE'),
('DELETE_USER',             'Delete a user',                   'USER',             'delete', 'ACTIVE'),
-- ROLE
('CREATE_ROLE',             'Create a new role',               'ROLE',             'create', 'ACTIVE'),
('READ_ROLE',               'View roles',                      'ROLE',             'read',   'ACTIVE'),
('UPDATE_ROLE',             'Update a role',                   'ROLE',             'update', 'ACTIVE'),
('DELETE_ROLE',             'Delete a role',                   'ROLE',             'delete', 'ACTIVE'),
-- PERMISSION
('CREATE_PERMISSION',       'Create a new permission',         'PERMISSION',       'create', 'ACTIVE'),
('READ_PERMISSION',         'View permissions',                'PERMISSION',       'read',   'ACTIVE'),
('UPDATE_PERMISSION',       'Update a permission',             'PERMISSION',       'update', 'ACTIVE'),
('DELETE_PERMISSION',       'Delete a permission',             'PERMISSION',       'delete', 'ACTIVE'),
-- CUSTOMER
('CREATE_CUSTOMER',         'Create a new customer',           'CUSTOMER',         'create', 'ACTIVE'),
('READ_CUSTOMER',           'View customers',                  'CUSTOMER',         'read',   'ACTIVE'),
('UPDATE_CUSTOMER',         'Update a customer',               'CUSTOMER',         'update', 'ACTIVE'),
('DELETE_CUSTOMER',         'Delete a customer',               'CUSTOMER',         'delete', 'ACTIVE'),
-- PRODUCT
('CREATE_PRODUCT',          'Create a new product',            'PRODUCT',          'create', 'ACTIVE'),
('READ_PRODUCT',            'View products',                   'PRODUCT',          'read',   'ACTIVE'),
('UPDATE_PRODUCT',          'Update a product',                'PRODUCT',          'update', 'ACTIVE'),
('DELETE_PRODUCT',          'Delete a product',                'PRODUCT',          'delete', 'ACTIVE'),
-- PRODUCT_CATEGORY
('CREATE_PRODUCT_CATEGORY', 'Create a product category',       'PRODUCT_CATEGORY', 'create', 'ACTIVE'),
('READ_PRODUCT_CATEGORY',   'View product categories',         'PRODUCT_CATEGORY', 'read',   'ACTIVE'),
('UPDATE_PRODUCT_CATEGORY', 'Update a product category',       'PRODUCT_CATEGORY', 'update', 'ACTIVE'),
('DELETE_PRODUCT_CATEGORY', 'Delete a product category',       'PRODUCT_CATEGORY', 'delete', 'ACTIVE'),
-- PRODUCT_LINE
('CREATE_PRODUCT_LINE',     'Create a product line',           'PRODUCT_LINE',     'create', 'ACTIVE'),
('READ_PRODUCT_LINE',       'View product lines',              'PRODUCT_LINE',     'read',   'ACTIVE'),
('UPDATE_PRODUCT_LINE',     'Update a product line',           'PRODUCT_LINE',     'update', 'ACTIVE'),
('DELETE_PRODUCT_LINE',     'Delete a product line',           'PRODUCT_LINE',     'delete', 'ACTIVE'),
-- PRODUCT_MODEL
('CREATE_PRODUCT_MODEL',    'Create a product model',          'PRODUCT_MODEL',    'create', 'ACTIVE'),
('READ_PRODUCT_MODEL',      'View product models',             'PRODUCT_MODEL',    'read',   'ACTIVE'),
('UPDATE_PRODUCT_MODEL',    'Update a product model',          'PRODUCT_MODEL',    'update', 'ACTIVE'),
('DELETE_PRODUCT_MODEL',    'Delete a product model',          'PRODUCT_MODEL',    'delete', 'ACTIVE'),
-- ORDER
('CREATE_ORDER',            'Create a new order',              'ORDER',            'create', 'ACTIVE'),
('READ_ORDER',              'View orders',                     'ORDER',            'read',   'ACTIVE'),
('UPDATE_ORDER',            'Update an order',                 'ORDER',            'update', 'ACTIVE'),
('DELETE_ORDER',            'Delete an order',                 'ORDER',            'delete', 'ACTIVE'),
-- STOCK
('CREATE_STOCK',            'Create stock movement',           'STOCK',            'create', 'ACTIVE'),
('READ_STOCK',              'View stock levels',               'STOCK',            'read',   'ACTIVE'),
('UPDATE_STOCK',            'Update stock',                    'STOCK',            'update', 'ACTIVE'),
('DELETE_STOCK',            'Delete stock record',             'STOCK',            'delete', 'ACTIVE'),
-- DELIVERY
('CREATE_DELIVERY',         'Create a new delivery',           'DELIVERY',         'create', 'ACTIVE'),
('READ_DELIVERY',           'View deliveries',                 'DELIVERY',         'read',   'ACTIVE'),
('UPDATE_DELIVERY',         'Update a delivery',               'DELIVERY',         'update', 'ACTIVE'),
('DELETE_DELIVERY',         'Delete a delivery',               'DELIVERY',         'delete', 'ACTIVE'),
-- DRIVER
('CREATE_DRIVER',           'Create a new driver',             'DRIVER',           'create', 'ACTIVE'),
('READ_DRIVER',             'View drivers',                    'DRIVER',           'read',   'ACTIVE'),
('UPDATE_DRIVER',           'Update a driver',                 'DRIVER',           'update', 'ACTIVE'),
('DELETE_DRIVER',           'Delete a driver',                 'DRIVER',           'delete', 'ACTIVE'),
-- COMMISSION
('CREATE_COMMISSION',       'Create a commission record',      'COMMISSION',       'create', 'ACTIVE'),
('READ_COMMISSION',         'View commissions',                'COMMISSION',       'read',   'ACTIVE'),
('UPDATE_COMMISSION',       'Update a commission',             'COMMISSION',       'update', 'ACTIVE'),
('DELETE_COMMISSION',       'Delete a commission',             'COMMISSION',       'delete', 'ACTIVE'),
-- SUPPLIER
('CREATE_SUPPLIER',         'Create a new supplier',           'SUPPLIER',         'create', 'ACTIVE'),
('READ_SUPPLIER',           'View suppliers',                  'SUPPLIER',         'read',   'ACTIVE'),
('UPDATE_SUPPLIER',         'Update a supplier',               'SUPPLIER',         'update', 'ACTIVE'),
('DELETE_SUPPLIER',         'Delete a supplier',               'SUPPLIER',         'delete', 'ACTIVE'),
-- PURCHASE
('CREATE_PURCHASE',         'Create a purchase order',         'PURCHASE',         'create', 'ACTIVE'),
('READ_PURCHASE',           'View purchase orders',            'PURCHASE',         'read',   'ACTIVE'),
('UPDATE_PURCHASE',         'Update a purchase order',         'PURCHASE',         'update', 'ACTIVE'),
('DELETE_PURCHASE',         'Delete a purchase order',         'PURCHASE',         'delete', 'ACTIVE'),
-- EXPENSE
('CREATE_EXPENSE',          'Create a new expense',            'EXPENSE',          'create', 'ACTIVE'),
('READ_EXPENSE',            'View expenses',                   'EXPENSE',          'read',   'ACTIVE'),
('UPDATE_EXPENSE',          'Update an expense',               'EXPENSE',          'update', 'ACTIVE'),
('DELETE_EXPENSE',          'Delete an expense',               'EXPENSE',          'delete', 'ACTIVE'),
-- EXPENSE_CATEGORY
('CREATE_EXPENSE_CATEGORY', 'Create an expense category',      'EXPENSE_CATEGORY', 'create', 'ACTIVE'),
('READ_EXPENSE_CATEGORY',   'View expense categories',         'EXPENSE_CATEGORY', 'read',   'ACTIVE'),
('UPDATE_EXPENSE_CATEGORY', 'Update an expense category',      'EXPENSE_CATEGORY', 'update', 'ACTIVE'),
('DELETE_EXPENSE_CATEGORY', 'Delete an expense category',      'EXPENSE_CATEGORY', 'delete', 'ACTIVE'),
-- MEDIA
('CREATE_MEDIA',            'Upload media',                    'MEDIA',            'create', 'ACTIVE'),
('READ_MEDIA',              'View media',                      'MEDIA',            'read',   'ACTIVE'),
('UPDATE_MEDIA',            'Update media',                    'MEDIA',            'update', 'ACTIVE'),
('DELETE_MEDIA',            'Delete media',                    'MEDIA',            'delete', 'ACTIVE'),
-- AUDIT_LOG
('CREATE_AUDIT_LOG',        'Create audit log entry',          'AUDIT_LOG',        'create', 'ACTIVE'),
('READ_AUDIT_LOG',          'View audit logs',                 'AUDIT_LOG',        'read',   'ACTIVE'),
('UPDATE_AUDIT_LOG',        'Update audit log',                'AUDIT_LOG',        'update', 'ACTIVE'),
('DELETE_AUDIT_LOG',        'Delete audit log',                'AUDIT_LOG',        'delete', 'ACTIVE'),
-- PAYROLL
('CREATE_PAYROLL',          'Create a payroll record',         'PAYROLL',          'create', 'ACTIVE'),
('READ_PAYROLL',            'View payroll records',            'PAYROLL',          'read',   'ACTIVE'),
('UPDATE_PAYROLL',          'Update a payroll record',         'PAYROLL',          'update', 'ACTIVE'),
('DELETE_PAYROLL',          'Delete a payroll record',         'PAYROLL',          'delete', 'ACTIVE'),
-- PRINT
('CREATE_PRINT',            'Generate print documents',        'PRINT',            'create', 'ACTIVE'),
('READ_PRINT',              'View print documents',            'PRINT',            'read',   'ACTIVE'),
('UPDATE_PRINT',            'Update print documents',          'PRINT',            'update', 'ACTIVE'),
('DELETE_PRINT',            'Delete print documents',          'PRINT',            'delete', 'ACTIVE')
ON CONFLICT (name) DO NOTHING;

-- Assign all permissions to ADMIN role
INSERT INTO role_permission (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;
