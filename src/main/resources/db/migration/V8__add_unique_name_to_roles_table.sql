ALTER TABLE roles
ADD CONSTRAINT uk_roles_name UNIQUE (name);
