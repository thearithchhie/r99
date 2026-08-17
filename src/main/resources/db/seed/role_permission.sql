-- Seed: role_permission
-- ADMIN → all 12 permissions
INSERT INTO role_permission (role_id, permission_id, created_at, updated_at)
SELECT r.id, p.id, NOW(), NOW()
FROM roles r, permissions p
WHERE r.name = 'ADMIN';

-- STAFF → CRUD on users, READ on roles and permissions
INSERT INTO role_permission (role_id, permission_id, created_at, updated_at)
SELECT r.id, p.id, NOW(), NOW()
FROM roles r, permissions p
WHERE r.name = 'STAFF'
  AND p.name IN ('CREATE_USER', 'READ_USER', 'UPDATE_USER', 'DELETE_USER',
                 'READ_ROLE', 'READ_PERMISSION');

-- USER → read own profile only
INSERT INTO role_permission (role_id, permission_id, created_at, updated_at)
SELECT r.id, p.id, NOW(), NOW()
FROM roles r, permissions p
WHERE r.name = 'USER'
  AND p.name = 'READ_USER';
