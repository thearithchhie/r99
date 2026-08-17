ALTER TABLE users
ADD COLUMN uuid UUID NOT NULL DEFAULT gen_random_uuid(),
ADD CONSTRAINT uk_users_uuid UNIQUE (uuid);
