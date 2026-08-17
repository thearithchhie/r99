ALTER TABLE roles
ADD COLUMN uuid UUID NOT NULL DEFAULT gen_random_uuid(),
ADD CONSTRAINT uk_roles_uuid UNIQUE (uuid);
