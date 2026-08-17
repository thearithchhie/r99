package com.r99.r99_shop_api.module.role.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.role.dto.request.RoleCreateRequest;
import com.r99.r99_shop_api.module.role.dto.response.RoleDetailResponse;
import com.r99.r99_shop_api.module.role.dto.response.RoleResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface RoleService {

    PagedResponse<RoleResponse> findAll(Pageable pageable);

    RoleDetailResponse findOne(UUID uuid);

    RoleDetailResponse updatePermissions(UUID uuid, List<UUID> permissionUuids);

    RoleResponse create(RoleCreateRequest request);
}
