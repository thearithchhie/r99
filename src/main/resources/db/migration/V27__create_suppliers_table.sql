CREATE TABLE IF NOT EXISTS suppliers (
    id             BIGSERIAL    NOT NULL,
    uuid           UUID         NOT NULL DEFAULT gen_random_uuid(),
    name           VARCHAR(150) NOT NULL,
    phone          VARCHAR(30),
    email          VARCHAR(150),
    address        TEXT,
    contact_person VARCHAR(150),
    status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by     VARCHAR(255),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by     VARCHAR(255),
    deleted_at     TIMESTAMPTZ,
    deleted_by     VARCHAR(255),
    CONSTRAINT pk_suppliers      PRIMARY KEY (id),
    CONSTRAINT uk_suppliers_uuid UNIQUE (uuid)
);

CREATE UNIQUE INDEX uk_suppliers_name_active ON suppliers(name) WHERE deleted_at IS NULL;
