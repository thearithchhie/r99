ALTER TABLE products
    ADD COLUMN variant_id BIGINT REFERENCES model_variants(id) ON DELETE SET NULL;

ALTER TABLE products
    DROP COLUMN model_id,
    DROP COLUMN size,
    DROP COLUMN color;

CREATE INDEX idx_products_variant_id ON products(variant_id);