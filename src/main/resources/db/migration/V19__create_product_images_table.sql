CREATE TABLE IF NOT EXISTS product_images (
    id          BIGSERIAL    NOT NULL,
    product_id  BIGINT       NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    media_id    BIGINT       NOT NULL REFERENCES media(id)    ON DELETE CASCADE,
    priority    SMALLINT     NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(255),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(255),
    deleted_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(255),
    CONSTRAINT pk_product_images             PRIMARY KEY (id),
    CONSTRAINT uk_product_images_product_media UNIQUE (product_id, media_id)
);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_images_priority   ON product_images(product_id, priority);
