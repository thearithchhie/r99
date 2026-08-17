CREATE TABLE IF NOT EXISTS audit_logs (
    id          BIGSERIAL    NOT NULL,
    user_id     BIGINT       NOT NULL,
    context     VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL,
    user_agent  TEXT         NOT NULL,
    operator    VARCHAR(100) NOT NULL,
    ip          VARCHAR(45)  NOT NULL,
    status_id   SMALLINT     NOT NULL DEFAULT 1,
    priority    INT          NOT NULL DEFAULT 1,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  BIGINT       NULL,
    updated_at  TIMESTAMPTZ  NULL,
    updated_by  BIGINT       NULL,
    deleted_at  TIMESTAMPTZ  NULL,
    deleted_by  BIGINT       NULL,
    CONSTRAINT pk_audit_logs PRIMARY KEY (id)
);
