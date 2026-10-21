-- Seed admin user
-- Default password: r99@staff (BCrypt cost 10)
INSERT INTO users (name, phone, password, status) VALUES
    ('Admin', '000-admin', '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE')
ON CONFLICT DO NOTHING;

-- Assign ADMIN role to admin user
INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.phone = '000-admin'
  AND r.name = 'ADMIN'
ON CONFLICT DO NOTHING;
