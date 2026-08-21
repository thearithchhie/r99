-- Seed roles
INSERT INTO roles (name, description) VALUES
    ('ADMIN', 'Administrator'),
    ('STAFF', 'Shop staff')
ON CONFLICT DO NOTHING;

-- Seed staff
-- Default password: r99@staff (BCrypt cost 10)
INSERT INTO users (name, phone, password, status) VALUES
    ('Nin Bunrima',   '000-nin-bunrima',   '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE'),
    ('Srean Muoyhuo', '000-srean-muoyhuo', '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE'),
    ('Chhay Tharen',  '000-chhay-tharen',  '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE'),
    ('Chhie Navi',    '000-chhie-navi',    '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE'),
    ('Son Srey Nich', '000-son-srey-nich', '$2a$10$SX2.NjrMrlsBTE9IcCgaT.Pjej0IY5X4gfrTydp8FHiK99KlQOFzC', 'ACTIVE')
ON CONFLICT DO NOTHING;

-- Assign STAFF role to all seeded staff
INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.phone IN ('000-nin-bunrima', '000-srean-muoyhuo', '000-chhay-tharen', '000-chhie-navi', '000-son-srey-nich')
  AND r.name = 'STAFF'
ON CONFLICT DO NOTHING;
