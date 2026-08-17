CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL,
    name       VARCHAR(100) NOT NULL,
    phone      VARCHAR(50)  NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    status     VARCHAR(50)  DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMPTZ,
    deleted_by VARCHAR(255),
    CONSTRAINT pk_users PRIMARY KEY (id)
);
