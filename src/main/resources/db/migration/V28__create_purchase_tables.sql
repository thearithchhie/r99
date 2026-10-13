CREATE TABLE IF NOT EXISTS purchase_orders (
    id              BIGSERIAL    NOT NULL,
    uuid            UUID         NOT NULL DEFAULT gen_random_uuid(),
    supplier_id     BIGINT       NOT NULL REFERENCES suppliers(id),
    order_number    VARCHAR(50)  NOT NULL,
    status          VARCHAR(30)  NOT NULL DEFAULT 'DRAFT',
    subtotal        NUMERIC(14,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    tax_amount      NUMERIC(14,2) NOT NULL DEFAULT 0,
    shipping_cost   NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount    NUMERIC(14,2) NOT NULL DEFAULT 0,
    note            TEXT,
    ordered_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(255),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(255),
    deleted_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(255),
    CONSTRAINT pk_purchase_orders             PRIMARY KEY (id),
    CONSTRAINT uk_purchase_orders_uuid        UNIQUE (uuid),
    CONSTRAINT uk_purchase_orders_order_number UNIQUE (order_number)
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id                  BIGSERIAL    NOT NULL,
    uuid                UUID         NOT NULL DEFAULT gen_random_uuid(),
    purchase_order_id   BIGINT       NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id          BIGINT       NOT NULL REFERENCES products(id),
    quantity            INTEGER      NOT NULL,
    received_quantity   INTEGER      NOT NULL DEFAULT 0,
    cost_price          NUMERIC(14,2) NOT NULL,
    discount_amount     NUMERIC(14,2) NOT NULL DEFAULT 0,
    subtotal            NUMERIC(14,2) NOT NULL,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_purchase_order_items      PRIMARY KEY (id),
    CONSTRAINT uk_purchase_order_items_uuid UNIQUE (uuid),
    CONSTRAINT chk_poi_quantity             CHECK (quantity > 0),
    CONSTRAINT chk_poi_cost_price           CHECK (cost_price >= 0),
    CONSTRAINT chk_poi_received_quantity    CHECK (received_quantity >= 0)
);

CREATE INDEX idx_purchase_orders_supplier_id ON purchase_orders(supplier_id);
CREATE INDEX idx_purchase_orders_status      ON purchase_orders(status);
CREATE INDEX idx_purchase_order_items_po_id  ON purchase_order_items(purchase_order_id);
