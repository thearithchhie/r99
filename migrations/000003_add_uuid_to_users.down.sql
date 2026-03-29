-- Drop index on uuid
DROP INDEX IF EXISTS idx_users_uuid;

-- Drop uuid column from users table
ALTER TABLE users DROP COLUMN IF EXISTS uuid;