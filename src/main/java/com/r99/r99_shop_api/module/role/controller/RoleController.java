package com.r99.r99_shop_api.module.role.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.role.dto.request.RoleCreateRequest;
import com.r99.r99_shop_api.module.role.dto.request.RoleUpdatePermissionsRequest;
import com.r99.r99_shop_api.module.role.dto.response.RoleDetailResponse;
import com.r99.r99_shop_api.module.role.dto.response.RoleResponse;
import com.r99.r99_shop_api.module.role.service.RoleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/roles")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<RoleResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(roleService.findAll(pageable)));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<RoleDetailResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(roleService.findOne(uuid)));
    }

    @PatchMapping("/{uuid}/permissions")
    public ResponseEntity<ApiResponse<RoleDetailResponse>> updatePermissions(
            @PathVariable UUID uuid,
            @Valid @RequestBody RoleUpdatePermissionsRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(roleService.updatePermissions(uuid, request.getPermissionUuids())));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RoleResponse>> create(@Valid @RequestBody RoleCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(roleService.create(request)));
    }
}
