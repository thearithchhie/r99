CREATE TABLE IF NOT EXISTS expense_categories (
    id          BIGSERIAL    NOT NULL,
    uuid        UUID         NOT NULL DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_expense_categories      PRIMARY KEY (id),
    CONSTRAINT uk_expense_categories_uuid UNIQUE (uuid)
);

CREATE UNIQUE INDEX uk_expense_categories_name_active ON expense_categories(name) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS expenses (
    id                   BIGSERIAL     NOT NULL,
    uuid                 UUID          NOT NULL DEFAULT gen_random_uuid(),
    expense_category_id  BIGINT        NOT NULL REFERENCES expense_categories(id),
    amount               NUMERIC(14,2) NOT NULL,
    description          TEXT,
    expense_date         DATE          NOT NULL,
    payment_method       VARCHAR(30),
    reference_number     VARCHAR(100),
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by           VARCHAR(255),
    updated_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by           VARCHAR(255),
    deleted_at           TIMESTAMPTZ,
    deleted_by           VARCHAR(255),
    CONSTRAINT pk_expenses      PRIMARY KEY (id),
    CONSTRAINT uk_expenses_uuid UNIQUE (uuid),
    CONSTRAINT chk_expenses_amount CHECK (amount > 0)
);

CREATE INDEX idx_expenses_category_id  ON expenses(expense_category_id);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date DESC);
CREATE INDEX idx_expenses_payment_method ON expenses(payment_method);
