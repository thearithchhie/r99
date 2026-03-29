-- Add UUID column to users table
ALTER TABLE users ADD COLUMN uuid UUID DEFAULT gen_random_uuid() UNIQUE;

-- Create index on uuid for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_uuid ON users(uuid);

-- Update existing records to have UUIDs
UPDATE users SET uuid = gen_random_uuid() WHERE uuid IS NULL;

-- Make the column NOT NULL after updating existing records
ALTER TABLE users ALTER COLUMN uuid SET NOT NULL;
