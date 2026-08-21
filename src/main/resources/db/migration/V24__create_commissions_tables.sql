CREATE TABLE IF NOT EXISTS staff_commissions (
    id          BIGSERIAL     NOT NULL,
    order_id    BIGINT        NOT NULL REFERENCES orders(id),
    staff_id    BIGINT        NOT NULL REFERENCES users(id),
    amount      NUMERIC(10,2) NOT NULL,
    is_weekend  BOOLEAN       NOT NULL DEFAULT FALSE,
    status      VARCHAR(20)   NOT NULL DEFAULT 'pending',
    payroll_id  BIGINT,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_staff_commissions PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS delivery_commissions (
    id           BIGSERIAL     NOT NULL,
    delivery_id  BIGINT        NOT NULL REFERENCES deliveries(id),
    driver_id    BIGINT        REFERENCES drivers(id) ON DELETE SET NULL,
    partner_type VARCHAR(30)   NOT NULL,
    amount       NUMERIC(10,2) NOT NULL,
    status       VARCHAR(20)   NOT NULL DEFAULT 'pending',
    payroll_id   BIGINT,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_delivery_commissions PRIMARY KEY (id)
);

CREATE INDEX idx_staff_commissions_order_id    ON staff_commissions(order_id);
CREATE INDEX idx_staff_commissions_staff_id    ON staff_commissions(staff_id);
CREATE INDEX idx_staff_commissions_status      ON staff_commissions(status);
CREATE INDEX idx_delivery_commissions_delivery ON delivery_commissions(delivery_id);
CREATE INDEX idx_delivery_commissions_status   ON delivery_commissions(status);
