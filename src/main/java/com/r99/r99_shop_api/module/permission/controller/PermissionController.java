package com.r99.r99_shop_api.module.permission.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.permission.dto.request.PermissionCreateRequest;
import com.r99.r99_shop_api.module.permission.dto.response.PermissionResponse;
import com.r99.r99_shop_api.module.permission.service.PermissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/permissions")
@RequiredArgsConstructor
public class PermissionController {

    private final PermissionService permissionService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<PermissionResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(permissionService.findAll(pageable)));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<PermissionResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(permissionService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PermissionResponse>> create(@Valid @RequestBody PermissionCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(permissionService.create(request)));
    }
}
