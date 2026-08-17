CREATE TABLE IF NOT EXISTS user_role (
    id            BIGSERIAL,
    user_id       BIGINT      NOT NULL,
    role_id       BIGINT      NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(255),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(255),
    deleted_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(255),
    CONSTRAINT pk_user_role          PRIMARY KEY (id),
    CONSTRAINT uk_user_role          UNIQUE (user_id, role_id),
    CONSTRAINT fk_user_role_role     FOREIGN KEY (role_id)       REFERENCES roles(id),
    CONSTRAINT fk_user_role_user     FOREIGN KEY (user_id)         REFERENCES users(id)
);
