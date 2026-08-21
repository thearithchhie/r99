CREATE TABLE IF NOT EXISTS drivers (
    id          BIGSERIAL    NOT NULL,
    uuid        UUID         NOT NULL DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    phone       VARCHAR(50)  NOT NULL,
    note        TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_drivers      PRIMARY KEY (id),
    CONSTRAINT uk_drivers_uuid UNIQUE (uuid)
);

CREATE INDEX idx_drivers_phone ON drivers(phone);
