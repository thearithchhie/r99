package com.r99.r99_shop_api.module.permission.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.permission.dto.request.PermissionCreateRequest;
import com.r99.r99_shop_api.module.permission.dto.response.PermissionResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface PermissionService {

    PagedResponse<PermissionResponse> findAll(Pageable pageable);

    PermissionResponse findOne(UUID uuid);

    PermissionResponse create(PermissionCreateRequest request);
}
