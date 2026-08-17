-- ============================================================
-- UI Test Seed
-- Creates 1 user with a restricted role that has only 2 permissions:
--   READ_USER  → view users module
--   READ_ROLE  → view roles module
--
-- Login:
--   phone:    +85500000001
--   password: password
-- ============================================================

-- 1. Add new role
INSERT INTO roles (name, description, status, created_at, updated_at) VALUES
('EDITOR', 'Limited staff: read-only on users and roles', 'ACTIVE', NOW(), NOW());

-- 2. Assign READ_USER + READ_ROLE to EDITOR
INSERT INTO role_permission (role_id, permission_id, created_at, updated_at)
SELECT r.id, p.id, NOW(), NOW()
FROM roles r, permissions p
WHERE r.name = 'EDITOR'
  AND p.name IN ('READ_USER', 'READ_ROLE');

-- 3. Add test user (password: "password", bcrypt cost 10)
INSERT INTO users (name, phone, password, status, created_at, updated_at) VALUES
('Test Editor', '+85500000001', '$2y$10$7k7tmFfnkFUGg9YqJBP1He5tuNlqsfF.yD2ETlKTB8gC3xMfQ4NjW', 'ACTIVE', NOW(), NOW());

-- 4. Assign EDITOR role to the test user
INSERT INTO user_role (user_id, role_id, created_at, updated_at)
SELECT u.id, r.id, NOW(), NOW()
FROM users u, roles r
WHERE u.phone = '+85500000001'
  AND r.name  = 'EDITOR';
