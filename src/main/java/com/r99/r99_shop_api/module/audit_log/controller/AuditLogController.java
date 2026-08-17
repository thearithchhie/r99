package com.r99.r99_shop_api.module.audit_log.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.dto.response.AuditLogResponse;
import com.r99.r99_shop_api.module.audit_log.service.AuditLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/audit-logs")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogService auditLogService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<AuditLogResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(auditLogService.findAll(pageable)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Void>> create(@Valid @RequestBody AuditLogCreateRequest request) {
        auditLogService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(null));
    }
}
