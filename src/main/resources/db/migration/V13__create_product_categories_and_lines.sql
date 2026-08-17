CREATE TABLE IF NOT EXISTS product_categories (
    id         BIGSERIAL    NOT NULL,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_product_categories      PRIMARY KEY (id),
    CONSTRAINT uk_product_categories_name UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS product_lines (
    id         BIGSERIAL    NOT NULL,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_product_lines      PRIMARY KEY (id),
    CONSTRAINT uk_product_lines_name UNIQUE (name)
);
