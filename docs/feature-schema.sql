-- ============================================================
-- R99 Shop API — Feature Schema
-- Modules: Customers, Products, Stock, Orders
--
-- Conventions (aligned with existing tables):
--   - BIGSERIAL primary key + separate uuid column
--   - VARCHAR for status fields (not ENUM)
--   - AuditBase columns: created_at, created_by, updated_at,
--     updated_by, deleted_at, deleted_by
--   - Soft delete via deleted_at
-- ============================================================

-- ============================================================
-- CUSTOMERS
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    id         BIGSERIAL    NOT NULL,
    uuid       UUID         NOT NULL DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    email      VARCHAR(255),
    phone      VARCHAR(50)  NOT NULL,
    status     VARCHAR(50)  NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMPTZ,
    deleted_by VARCHAR(255),
    CONSTRAINT pk_customers      PRIMARY KEY (id),
    CONSTRAINT uk_customers_uuid  UNIQUE (uuid),
    CONSTRAINT uk_customers_phone UNIQUE (phone)
);

-- Discussion point:
-- Should email be required (NOT NULL UNIQUE) or optional?
-- Schema doc has email UNIQUE NOT NULL, but customers in KH
-- market often only have phone.

-- ============================================================
-- PRODUCT CATALOGUE
-- ============================================================

-- Simple lookup — no uuid, no soft delete, rarely changes
CREATE TABLE IF NOT EXISTS product_categories (
    id         BIGSERIAL    NOT NULL,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_product_categories      PRIMARY KEY (id),
    CONSTRAINT uk_product_categories_name UNIQUE (name)
);

-- Simple lookup — no uuid, no soft delete, rarely changes
CREATE TABLE IF NOT EXISTS product_lines (
    id         BIGSERIAL    NOT NULL,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_product_lines      PRIMARY KEY (id),
    CONSTRAINT uk_product_lines_name UNIQUE (name)
);

-- A garment template that groups size x color variants
CREATE TABLE IF NOT EXISTS product_models (
    id          BIGSERIAL    NOT NULL,
    uuid        UUID         NOT NULL DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_product_models      PRIMARY KEY (id),
    CONSTRAINT uk_product_models_uuid UNIQUE (uuid)
);

-- Each unique size x color combination under a model
CREATE TABLE IF NOT EXISTS model_variants (
    id         BIGSERIAL   NOT NULL,
    uuid       UUID        NOT NULL DEFAULT gen_random_uuid(),
    model_id   BIGINT      NOT NULL REFERENCES product_models(id) ON DELETE CASCADE,
    size       VARCHAR(20) NOT NULL,
    color      VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_model_variants                    PRIMARY KEY (id),
    CONSTRAINT uk_model_variants_uuid               UNIQUE (uuid),
    CONSTRAINT uk_model_variants_model_size_color   UNIQUE (model_id, size, color)
);

-- Ordered images per variant
CREATE TABLE IF NOT EXISTS model_variant_images (
    id         BIGSERIAL     NOT NULL,
    variant_id BIGINT        NOT NULL REFERENCES model_variants(id) ON DELETE CASCADE,
    url        VARCHAR(1000) NOT NULL,
    sort_order SMALLINT      NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_model_variant_images PRIMARY KEY (id)
);

-- Individual SKUs
CREATE TABLE IF NOT EXISTS products (
    id          BIGSERIAL     NOT NULL,
    uuid        UUID          NOT NULL DEFAULT gen_random_uuid(),
    code        VARCHAR(50)   NOT NULL,
    -- code: short product identifier e.g. 282, 91 — unique per size/color
    name        VARCHAR(255)  NOT NULL,
    sku         VARCHAR(100)  NOT NULL,
    category_id BIGINT        REFERENCES product_categories(id) ON DELETE SET NULL,
    line_id     BIGINT        REFERENCES product_lines(id)      ON DELETE SET NULL,
    model_id    BIGINT        REFERENCES product_models(id)     ON DELETE SET NULL,
    size        VARCHAR(20),
    color       VARCHAR(50),
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cost        NUMERIC(10,2) NOT NULL CHECK (cost  >= 0),
    tone        SMALLINT      NOT NULL DEFAULT 0 CHECK (tone BETWEEN 0 AND 5),
    status      VARCHAR(50)   NOT NULL DEFAULT 'in_stock',
    -- status values: in_stock | low_stock | out_of_stock
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_products      PRIMARY KEY (id),
    CONSTRAINT uk_products_uuid UNIQUE (uuid),
    CONSTRAINT uk_products_code UNIQUE (code),
    CONSTRAINT uk_products_sku  UNIQUE (sku)
);

-- Discussion point:
-- model_id is optional (nullable). A product can exist
-- standalone without being part of a model/variant hierarchy.

-- ============================================================
-- STOCK
-- Two tables always updated together in the same transaction:
--   stock_levels  — current snapshot (fast reads)
--   stock_movements — append-only ledger (full history)
-- ============================================================

-- Current quantity per product OR per variant (never both)
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

-- Append-only ledger — NEVER update or delete rows
CREATE TABLE IF NOT EXISTS stock_movements (
    id           BIGSERIAL    NOT NULL,
    product_id   BIGINT       REFERENCES products(id)       ON DELETE SET NULL,
    variant_id   BIGINT       REFERENCES model_variants(id) ON DELETE SET NULL,
    delta        INTEGER      NOT NULL,
    -- delta: positive = stock in, negative = stock out
    reason       VARCHAR(50)  NOT NULL,
    -- reason values: initial | purchase | sale | return | adjustment | damage | import
    reference_id VARCHAR(255),
    -- reference_id: order ID or purchase order that caused the change
    note         TEXT,
    created_by   BIGINT       REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_stock_movements PRIMARY KEY (id),
    CONSTRAINT chk_movement_one_owner CHECK (
        (product_id IS NOT NULL AND variant_id IS NULL) OR
        (product_id IS NULL     AND variant_id IS NOT NULL)
    )
);

-- ============================================================
-- ORDERS
-- ============================================================

-- Discussion point:
-- Schema doc uses VARCHAR(20) human-readable PK like R99-104722.
-- We could also use BIGSERIAL + a generated order_number column.
-- Which do you prefer?

CREATE TABLE IF NOT EXISTS orders (
    id            VARCHAR(20)   NOT NULL,
    -- format: R99-XXXXXX (e.g. R99-104722)
    uuid          UUID          NOT NULL DEFAULT gen_random_uuid(),
    customer_id   BIGINT        REFERENCES customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(255)  NOT NULL,
    -- denormalized: preserved if customer is deleted
    city          VARCHAR(255),
    status        VARCHAR(50)   NOT NULL DEFAULT 'processing',
    -- status values: processing | paid | shipped | delivered | refunded
    ship          VARCHAR(100),
    -- shipping carrier: J&T | DHL | Ninja Van | etc.
    total         NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(255),
    updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(255),
    deleted_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(255),
    CONSTRAINT pk_orders      PRIMARY KEY (id),
    CONSTRAINT uk_orders_uuid UNIQUE (uuid)
);

CREATE TABLE IF NOT EXISTS order_items (
    id           BIGSERIAL     NOT NULL,
    order_id     VARCHAR(20)   NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id   BIGINT        REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255)  NOT NULL,
    -- denormalized: preserved if product is deleted
    size         VARCHAR(20),
    color        VARCHAR(50),
    tone         SMALLINT,
    qty          INTEGER       NOT NULL CHECK (qty > 0),
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    -- price frozen at time of purchase
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_order_items PRIMARY KEY (id)
);

-- ============================================================
-- INDEXES
-- ============================================================

-- Customers
CREATE INDEX idx_customers_phone  ON customers(phone);
CREATE INDEX idx_customers_status ON customers(status);

-- Products
CREATE INDEX idx_products_sku         ON products(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_status      ON products(status);
CREATE INDEX idx_products_model_id    ON products(model_id);

-- Variants & Images
CREATE INDEX idx_model_variants_model_id   ON model_variants(model_id);
CREATE INDEX idx_variant_images_variant_id ON model_variant_images(variant_id);

-- Stock
CREATE INDEX idx_stock_levels_product_id    ON stock_levels(product_id);
CREATE INDEX idx_stock_levels_variant_id    ON stock_levels(variant_id);
CREATE INDEX idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_variant_id ON stock_movements(variant_id);
CREATE INDEX idx_stock_movements_reason     ON stock_movements(reason);
CREATE INDEX idx_stock_movements_created_at ON stock_movements(created_at DESC);

-- Orders
CREATE INDEX idx_orders_customer_id    ON orders(customer_id);
CREATE INDEX idx_orders_status         ON orders(status);
CREATE INDEX idx_orders_created_at     ON orders(created_at DESC);
CREATE INDEX idx_order_items_order_id  ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
