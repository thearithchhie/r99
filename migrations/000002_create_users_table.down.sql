-- Drop trigger
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Drop index
DROP INDEX IF EXISTS idx_users_email;

-- Drop users table
DROP TABLE IF EXISTS users;