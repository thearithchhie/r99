CREATE TABLE IF NOT EXISTS payrolls (
    id           BIGSERIAL     NOT NULL,
    uuid         UUID          NOT NULL DEFAULT gen_random_uuid(),
    week_start   DATE          NOT NULL,
    week_end     DATE          NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    status       VARCHAR(20)   NOT NULL DEFAULT 'draft',
    paid_at      TIMESTAMPTZ,
    note         TEXT,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by   VARCHAR(255),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by   VARCHAR(255),
    CONSTRAINT pk_payrolls      PRIMARY KEY (id),
    CONSTRAINT uk_payrolls_uuid UNIQUE (uuid)
);

CREATE TABLE IF NOT EXISTS payroll_items (
    id               BIGSERIAL     NOT NULL,
    payroll_id       BIGINT        NOT NULL REFERENCES payrolls(id) ON DELETE CASCADE,
    staff_id         BIGINT        REFERENCES users(id)   ON DELETE SET NULL,
    driver_id        BIGINT        REFERENCES drivers(id) ON DELETE SET NULL,
    recipient_type   VARCHAR(20)   NOT NULL,
    commission_count INTEGER       NOT NULL DEFAULT 0,
    total_amount     NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_payroll_items PRIMARY KEY (id),
    CONSTRAINT chk_payroll_item_recipient CHECK (
        (staff_id IS NOT NULL AND driver_id IS NULL) OR
        (staff_id IS NULL     AND driver_id IS NOT NULL)
    )
);

ALTER TABLE staff_commissions    ADD CONSTRAINT fk_staff_commissions_payroll    FOREIGN KEY (payroll_id) REFERENCES payrolls(id);
ALTER TABLE delivery_commissions ADD CONSTRAINT fk_delivery_commissions_payroll FOREIGN KEY (payroll_id) REFERENCES payrolls(id);

CREATE INDEX idx_payrolls_status          ON payrolls(status);
CREATE INDEX idx_payrolls_week_start      ON payrolls(week_start);
CREATE INDEX idx_payroll_items_payroll_id ON payroll_items(payroll_id);
