package com.r99.r99_shop_api.module.permission.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.service.AuditLogService;
import com.r99.r99_shop_api.module.permission.dto.request.PermissionCreateRequest;
import com.r99.r99_shop_api.module.permission.dto.response.PermissionResponse;
import com.r99.r99_shop_api.module.permission.entity.Permission;
import com.r99.r99_shop_api.module.permission.repository.PermissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PermissionServiceImpl implements PermissionService {

    private final PermissionRepository permissionRepository;
    private final AuditLogService auditLogService;

    @Override
    public PagedResponse<PermissionResponse> findAll(Pageable pageable) {
        Page<PermissionResponse> page = permissionRepository
                .findAll(PageableUtil.withDefaultSort(pageable))
                .map(this::toResponse);
        return PagedResponse.of(page, "permissions");
    }

    @Override
    public PermissionResponse findOne(UUID uuid) {
        Permission permission = permissionRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Data not found"));
        return toResponse(permission);
    }

    @Override
    public PermissionResponse create(PermissionCreateRequest request) {
        if (permissionRepository.existsByName(request.getName())) {
            throw new AppException("Permission name already exists");
        }
        Permission permission = Permission.builder()
                .name(request.getName())
                .description(request.getDescription())
                .module(request.getModule())
                .action(request.getAction())
                .build();
        Permission saved = permissionRepository.save(permission);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Create Permission")
                .description(String.format("Permission '%s' (module: %s, action: %s) has been created successfully",
                        saved.getName(), saved.getModule(), saved.getAction()))
                .build());

        return toResponse(saved);
    }

    private PermissionResponse toResponse(Permission permission) {
        return PermissionResponse.builder()
                .id(permission.getId())
                .uuid(permission.getUuid())
                .name(permission.getName())
                .description(permission.getDescription())
                .module(permission.getModule())
                .action(permission.getAction())
                .status(permission.getStatus())
                .build();
    }
}
