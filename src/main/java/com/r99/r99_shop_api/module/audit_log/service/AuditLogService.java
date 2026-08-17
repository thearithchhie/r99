package com.r99.r99_shop_api.module.audit_log.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.dto.response.AuditLogResponse;
import org.springframework.data.domain.Pageable;

public interface AuditLogService {

    PagedResponse<AuditLogResponse> findAll(Pageable pageable);

    void create(AuditLogCreateRequest request);
}
