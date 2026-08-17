package com.r99.r99_shop_api.module.audit_log.dto.request;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuditLogCreateRequest {

    private String context;
    private String description;
}
