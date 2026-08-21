package com.r99.r99_shop_api.module.role.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.service.AuditLogService;
import com.r99.r99_shop_api.module.permission.dto.response.PermissionResponse;
import com.r99.r99_shop_api.module.permission.entity.Permission;
import com.r99.r99_shop_api.module.permission.repository.PermissionRepository;
import com.r99.r99_shop_api.module.role.dto.request.RoleCreateRequest;
import com.r99.r99_shop_api.module.role.dto.response.RoleDetailResponse;
import com.r99.r99_shop_api.module.role.dto.response.RoleResponse;
import com.r99.r99_shop_api.module.role.entity.Role;
import com.r99.r99_shop_api.module.role.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;
    private final AuditLogService auditLogService;

    @Override
    public PagedResponse<RoleResponse> findAll(Pageable pageable) {
        Page<RoleResponse> page = roleRepository.findAll(PageableUtil.withDefaultSort(pageable)).map(this::toResponse);
        return PagedResponse.of(page, "roles");
    }

    @Override
    @Transactional(readOnly = true)
    public RoleDetailResponse findOne(UUID uuid) {
        Role role = roleRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Data not found"));
        return toDetailResponse(role);
    }

    @Override
    @Transactional
    public RoleDetailResponse updatePermissions(UUID uuid, List<UUID> permissionUuids) {
        Role role = roleRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Role not found"));

        List<Permission> current = role.getPermissions();
        List<Permission> incoming = permissionRepository.findByUuidIn(permissionUuids);

        Set<Long> currentIds = current.stream().map(Permission::getId).collect(Collectors.toSet());
        Set<Long> incomingIds = incoming.stream().map(Permission::getId).collect(Collectors.toSet());

        List<Permission> toAdd    = incoming.stream().filter(p -> !currentIds.contains(p.getId())).toList();
        List<Permission> toRemove = current.stream().filter(p -> !incomingIds.contains(p.getId())).toList();

        List<Permission> updated = new ArrayList<>(current);
        updated.removeAll(toRemove);
        updated.addAll(toAdd);

        role.setPermissions(updated);
        roleRepository.save(role);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Update Role Permissions")
                .description(String.format("Permissions of role '%s' have been updated successfully", role.getName()))
                .build());

        return findOne(uuid);
    }

    @Override
    public RoleResponse create(RoleCreateRequest request) {
        if (roleRepository.existsByName(request.getName())) {
            throw new AppException("Role name already exists");
        }
        Role role = Role.builder()
                .name(request.getName())
                .description(request.getDescription())
                .build();
        Role saved = roleRepository.save(role);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Create Role")
                .description(String.format("Role '%s' has been created successfully", saved.getName()))
                .build());

        return toResponse(saved);
    }

    private RoleResponse toResponse(Role role) {
        return RoleResponse.builder()
                .id(role.getId())
                .uuid(role.getUuid())
                .name(role.getName())
                .description(role.getDescription())
                .userCount(roleRepository.countUsersByRoleId(role.getId()))
                .permissionCount(roleRepository.countPermissionsByRoleId(role.getId()))
                .status(role.getStatus())
                .createdBy(role.getCreatedBy())
                .createdAt(role.getCreatedAt())
                .updatedAt(role.getUpdatedAt())
                .updatedBy(role.getUpdatedBy())
                .build();
    }

    private RoleDetailResponse toDetailResponse(Role role) {
        List<PermissionResponse> permissions = role.getPermissions().stream()
                .map(p -> PermissionResponse.builder()
                        .id(p.getId())
                        .uuid(p.getUuid())
                        .name(p.getName())
                        .description(p.getDescription())
                        .module(p.getModule())
                        .action(p.getAction())
                        .status(p.getStatus())
                        .build())
                .toList();

        return RoleDetailResponse.builder()
                .id(role.getId())
                .uuid(role.getUuid())
                .name(role.getName())
                .description(role.getDescription())
                .status(role.getStatus())
                .permissions(permissions)
                .createdBy(role.getCreatedBy())
                .createdAt(role.getCreatedAt())
                .updatedAt(role.getUpdatedAt())
                .updatedBy(role.getUpdatedBy())
                .build();
    }
}
