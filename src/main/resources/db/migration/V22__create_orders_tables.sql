CREATE TABLE IF NOT EXISTS orders (
    id              BIGSERIAL     NOT NULL,
    uuid            UUID          NOT NULL DEFAULT gen_random_uuid(),
    customer_id     BIGINT        NOT NULL REFERENCES customers(id),
    staff_id        BIGINT        REFERENCES users(id)    ON DELETE SET NULL,
    page_source     VARCHAR(20)   NOT NULL,
    payment_type    VARCHAR(30)   NOT NULL,
    payment_method  VARCHAR(30),
    status          VARCHAR(30)   NOT NULL DEFAULT 'pending',
    return_reason   VARCHAR(30),
    subtotal        NUMERIC(10,2) NOT NULL,
    delivery_fee    NUMERIC(10,2) NOT NULL DEFAULT 2.00,
    is_promotion    BOOLEAN       NOT NULL DEFAULT FALSE,
    total_amount    NUMERIC(10,2) NOT NULL,
    note            TEXT,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(255),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(255),
    deleted_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(255),
    CONSTRAINT pk_orders      PRIMARY KEY (id),
    CONSTRAINT uk_orders_uuid UNIQUE (uuid)
);

CREATE TABLE IF NOT EXISTS order_items (
    id          BIGSERIAL     NOT NULL,
    order_id    BIGINT        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  BIGINT        NOT NULL REFERENCES products(id),
    quantity    INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL,
    unit_cost   NUMERIC(10,2) NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_order_items PRIMARY KEY (id)
);

CREATE INDEX idx_orders_customer_id   ON orders(customer_id);
CREATE INDEX idx_orders_staff_id      ON orders(staff_id);
CREATE INDEX idx_orders_status        ON orders(status);
CREATE INDEX idx_orders_page_source   ON orders(page_source);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
