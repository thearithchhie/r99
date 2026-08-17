package com.r99.r99_shop_api.module.audit_log.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.dto.response.AuditLogResponse;
import com.r99.r99_shop_api.module.audit_log.entity.AuditLog;
import com.r99.r99_shop_api.module.audit_log.repository.AuditLogRepository;
import com.r99.r99_shop_api.module.auth.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<AuditLogResponse> findAll(Pageable pageable) {
        Page<AuditLogResponse> page = auditLogRepository
                .findAll(PageableUtil.withDefaultSort(pageable))
                .map(this::toResponse);
        return PagedResponse.of(page, "audit_logs");
    }

    @Override
    public void create(AuditLogCreateRequest request) {
        String userAgent = "unknown";
        String ip = "unknown";
        try {
            HttpServletRequest httpRequest = ((ServletRequestAttributes)
                    RequestContextHolder.currentRequestAttributes()).getRequest();
            String rawUserAgent = httpRequest.getHeader("User-Agent");
            userAgent = rawUserAgent != null ? rawUserAgent : "unknown";
            ip = httpRequest.getRemoteAddr();
        } catch (Exception ignored) {}

        String operator = "system";
        Long userId = 0L;
        Long createdBy = null;

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User currentUser) {
            operator = currentUser.getPhone();
            userId = currentUser.getId();
            createdBy = currentUser.getId();
        }

        auditLogRepository.save(AuditLog.builder()
                .userId(userId)
                .context(request.getContext())
                .description(request.getDescription())
                .userAgent(userAgent)
                .operator(operator)
                .ip(ip)
                .createdBy(createdBy)
                .build());
    }

    private AuditLogResponse toResponse(AuditLog log) {
        String userName = log.getUser() != null ? log.getUser().getName() : null;
        return AuditLogResponse.builder()
                .id(log.getId())
                .userId(log.getUserId())
                .userName(userName)
                .context(log.getContext())
                .description(log.getDescription())
                .userAgent(log.getUserAgent())
                .operator(log.getOperator())
                .ip(log.getIp())
                .statusId(log.getStatusId())
                .priority(log.getPriority())
                .createdBy(log.getCreatedBy())
                .createdAt(log.getCreatedAt())
                .build();
    }
}
