CREATE TABLE IF NOT EXISTS products (
    id          BIGSERIAL     NOT NULL,
    uuid        UUID          NOT NULL DEFAULT gen_random_uuid(),
    code        VARCHAR(50)   NOT NULL,
    name        VARCHAR(255)  NOT NULL,
    sku         VARCHAR(100),
    category_id BIGINT        REFERENCES product_categories(id) ON DELETE SET NULL,
    line_id     BIGINT        REFERENCES product_lines(id)      ON DELETE SET NULL,
    model_id    BIGINT        REFERENCES product_models(id)     ON DELETE SET NULL,
    size        VARCHAR(20),
    color       VARCHAR(50),
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cost        NUMERIC(10,2) NOT NULL CHECK (cost  >= 0),
    tone        SMALLINT      NOT NULL DEFAULT 0 CHECK (tone BETWEEN 0 AND 5),
    status      VARCHAR(50)   NOT NULL DEFAULT 'in_stock',
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_products      PRIMARY KEY (id),
    CONSTRAINT uk_products_uuid UNIQUE (uuid),
    CONSTRAINT uk_products_code UNIQUE (code)
);

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_model_id    ON products(model_id);
CREATE INDEX idx_products_status      ON products(status);
