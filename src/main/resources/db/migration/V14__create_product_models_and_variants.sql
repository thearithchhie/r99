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

CREATE TABLE IF NOT EXISTS model_variants (
    id         BIGSERIAL   NOT NULL,
    uuid       UUID        NOT NULL DEFAULT gen_random_uuid(),
    model_id   BIGINT      NOT NULL REFERENCES product_models(id) ON DELETE CASCADE,
    size       VARCHAR(20) NOT NULL,
    color      VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_model_variants                  PRIMARY KEY (id),
    CONSTRAINT uk_model_variants_uuid             UNIQUE (uuid),
    CONSTRAINT uk_model_variants_model_size_color UNIQUE (model_id, size, color)
);

CREATE TABLE IF NOT EXISTS model_variant_images (
    id         BIGSERIAL     NOT NULL,
    variant_id BIGINT        NOT NULL REFERENCES model_variants(id) ON DELETE CASCADE,
    url        VARCHAR(1000) NOT NULL,
    sort_order SMALLINT      NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_model_variant_images PRIMARY KEY (id)
);

CREATE INDEX idx_model_variants_model_id   ON model_variants(model_id);
CREATE INDEX idx_variant_images_variant_id ON model_variant_images(variant_id);
