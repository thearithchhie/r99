-- Seed: permissions (CRUD per module)
INSERT INTO permissions (name, description, module, action, status, created_at, updated_at) VALUES
-- Users module
('CREATE_USER',       'Create a new user',             'USER',       'create', 'ACTIVE', NOW(), NOW()),
('READ_USER',         'View users',                    'USER',       'read',   'ACTIVE', NOW(), NOW()),
('UPDATE_USER',       'Update an existing user',       'USER',       'update', 'ACTIVE', NOW(), NOW()),
('DELETE_USER',       'Delete a user',                 'USER',       'delete', 'ACTIVE', NOW(), NOW()),
-- Roles module
('CREATE_ROLE',       'Create a new role',             'ROLE',       'create', 'ACTIVE', NOW(), NOW()),
('READ_ROLE',         'View roles',                    'ROLE',       'read',   'ACTIVE', NOW(), NOW()),
('UPDATE_ROLE',       'Update an existing role',       'ROLE',       'update', 'ACTIVE', NOW(), NOW()),
('DELETE_ROLE',       'Delete a role',                 'ROLE',       'delete', 'ACTIVE', NOW(), NOW()),
-- Permissions module
('CREATE_PERMISSION', 'Create a new permission',       'PERMISSION', 'create', 'ACTIVE', NOW(), NOW()),
('READ_PERMISSION',   'View permissions',              'PERMISSION', 'read',   'ACTIVE', NOW(), NOW()),
('UPDATE_PERMISSION', 'Update an existing permission', 'PERMISSION', 'update', 'ACTIVE', NOW(), NOW()),
('DELETE_PERMISSION', 'Delete a permission',           'PERMISSION', 'delete', 'ACTIVE', NOW(), NOW());
