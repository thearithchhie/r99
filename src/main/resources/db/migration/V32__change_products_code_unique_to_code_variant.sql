ALTER TABLE products DROP CONSTRAINT uk_products_code;

ALTER TABLE products
    ADD CONSTRAINT uk_products_code_variant UNIQUE NULLS NOT DISTINCT (code, variant_id);
