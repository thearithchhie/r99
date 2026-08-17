ALTER TABLE permissions
ADD COLUMN uuid UUID NOT NULL DEFAULT gen_random_uuid(),
ADD CONSTRAINT uk_permissions_uuid UNIQUE (uuid),
ADD CONSTRAINT uk_permissions_name UNIQUE (name);
