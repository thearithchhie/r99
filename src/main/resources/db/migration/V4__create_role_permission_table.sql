CREATE TABLE IF NOT EXISTS role_permission (
    id            BIGSERIAL,
    role_id       BIGINT      NOT NULL,
    permission_id BIGINT      NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(255),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(255),
    deleted_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(255),
    CONSTRAINT pk_role_permission          PRIMARY KEY (id),
    CONSTRAINT uk_role_permission          UNIQUE (role_id, permission_id),
    CONSTRAINT fk_role_permission_role     FOREIGN KEY (role_id)       REFERENCES roles(id),
    CONSTRAINT fk_role_permission_perm     FOREIGN KEY (permission_id) REFERENCES permissions(id)
);
