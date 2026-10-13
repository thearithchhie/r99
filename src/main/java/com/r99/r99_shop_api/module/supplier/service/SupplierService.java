package com.r99.r99_shop_api.module.supplier.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierCreateRequest;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierUpdateRequest;
import com.r99.r99_shop_api.module.supplier.dto.response.SupplierResponse;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface SupplierService {
    PagedResponse<SupplierResponse> findAll(String search, SupplierStatus status, Pageable pageable);
    SupplierResponse findOne(UUID uuid);
    SupplierResponse create(SupplierCreateRequest request);
    SupplierResponse update(UUID uuid, SupplierUpdateRequest request);
    void delete(UUID uuid);
}
