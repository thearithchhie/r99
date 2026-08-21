CREATE TABLE IF NOT EXISTS customers (
    id            BIGSERIAL    NOT NULL,
    uuid          UUID         NOT NULL DEFAULT gen_random_uuid(),
    name          VARCHAR(255) NOT NULL,
    phone         VARCHAR(50)  NOT NULL,
    address       TEXT,
    province      VARCHAR(100),
    facebook_name VARCHAR(255),
    note          TEXT,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(255),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(255),
    deleted_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(255),
    CONSTRAINT pk_customers      PRIMARY KEY (id),
    CONSTRAINT uk_customers_uuid UNIQUE (uuid)
);

CREATE INDEX idx_customers_phone ON customers(phone);
