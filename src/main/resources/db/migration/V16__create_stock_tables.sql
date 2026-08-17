CREATE TABLE IF NOT EXISTS stock_levels (
    id         BIGSERIAL   NOT NULL,
    product_id BIGINT      UNIQUE REFERENCES products(id)       ON DELETE CASCADE,
    variant_id BIGINT      UNIQUE REFERENCES model_variants(id) ON DELETE CASCADE,
    quantity   INTEGER     NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_stock_levels PRIMARY KEY (id),
    CONSTRAINT chk_stock_one_owner CHECK (
        (product_id IS NOT NULL AND variant_id IS NULL) OR
        (product_id IS NULL     AND variant_id IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS stock_movements (
    id           BIGSERIAL    NOT NULL,
    product_id   BIGINT       REFERENCES products(id)       ON DELETE SET NULL,
    variant_id   BIGINT       REFERENCES model_variants(id) ON DELETE SET NULL,
    delta        INTEGER      NOT NULL,
    reason       VARCHAR(50)  NOT NULL,
    reference_id VARCHAR(255),
    note         TEXT,
    created_by   BIGINT       REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_stock_movements PRIMARY KEY (id),
    CONSTRAINT chk_movement_one_owner CHECK (
        (product_id IS NOT NULL AND variant_id IS NULL) OR
        (product_id IS NULL     AND variant_id IS NOT NULL)
    )
);

CREATE INDEX idx_stock_levels_product_id    ON stock_levels(product_id);
CREATE INDEX idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_reason     ON stock_movements(reason);
CREATE INDEX idx_stock_movements_created_at ON stock_movements(created_at DESC);
