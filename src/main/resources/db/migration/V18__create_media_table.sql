CREATE TABLE IF NOT EXISTS media (
    id           BIGSERIAL     NOT NULL,
    file_name    VARCHAR(255)  NOT NULL,
    file_url     VARCHAR(1000) NOT NULL,
    storage_type VARCHAR(50)   NOT NULL,
    mime_type    VARCHAR(100)  NOT NULL,
    file_size    BIGINT        NOT NULL,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    deleted_at   TIMESTAMPTZ,
    CONSTRAINT pk_media PRIMARY KEY (id)
);

CREATE INDEX idx_media_storage_type ON media(storage_type);
CREATE INDEX idx_media_deleted_at   ON media(deleted_at);
