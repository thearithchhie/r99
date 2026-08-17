CREATE TABLE IF NOT EXISTS permissions (
    id          BIGSERIAL,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    status      VARCHAR(50)  DEFAULT 'ACTIVE',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_permissions PRIMARY KEY (id)
);
