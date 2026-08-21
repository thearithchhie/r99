CREATE TABLE IF NOT EXISTS deliveries (
    id                     BIGSERIAL     NOT NULL,
    uuid                   UUID          NOT NULL DEFAULT gen_random_uuid(),
    order_id               BIGINT        NOT NULL REFERENCES orders(id),
    driver_id              BIGINT        REFERENCES drivers(id) ON DELETE SET NULL,
    partner_type           VARCHAR(30)   NOT NULL,
    delivery_cost          NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    commission_earned      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    commission_received_at TIMESTAMPTZ,
    status                 VARCHAR(30)   NOT NULL DEFAULT 'pending',
    recipient_name         VARCHAR(255)  NOT NULL,
    recipient_phone        VARCHAR(50)   NOT NULL,
    recipient_address      TEXT          NOT NULL,
    note                   TEXT,
    delivered_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by             VARCHAR(255),
    updated_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by             VARCHAR(255),
    deleted_at             TIMESTAMPTZ,
    deleted_by             VARCHAR(255),
    CONSTRAINT pk_deliveries      PRIMARY KEY (id),
    CONSTRAINT uk_deliveries_uuid UNIQUE (uuid)
);

CREATE INDEX idx_deliveries_order_id  ON deliveries(order_id);
CREATE INDEX idx_deliveries_driver_id ON deliveries(driver_id);
CREATE INDEX idx_deliveries_status    ON deliveries(status);
