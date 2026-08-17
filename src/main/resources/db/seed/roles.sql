-- Seed: roles
INSERT INTO roles (name, description, status, created_at, updated_at) VALUES
('ADMIN',  'Full system access',           'ACTIVE', NOW(), NOW()),
('STAFF',  'Manage products and orders',   'ACTIVE', NOW(), NOW()),
('USER',   'Customer, can browse and buy', 'ACTIVE', NOW(), NOW());
