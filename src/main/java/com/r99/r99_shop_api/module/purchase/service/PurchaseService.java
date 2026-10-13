package com.r99.r99_shop_api.module.purchase.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseCreateRequest;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseReceiveRequest;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseArrivalResponse;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseResponse;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseStatus;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface PurchaseService {
    PagedResponse<PurchaseResponse> findAll(PurchaseStatus status, Pageable pageable);
    PagedResponse<PurchaseResponse> findAllBySupplier(UUID supplierUuid, Pageable pageable);
    PurchaseResponse findOne(UUID uuid);
    PurchaseResponse create(PurchaseCreateRequest request);
    PurchaseResponse update(UUID uuid, PurchaseCreateRequest request);
    PurchaseResponse confirm(UUID uuid);
    PurchaseResponse receive(UUID uuid, PurchaseReceiveRequest request);
    PurchaseResponse cancel(UUID uuid);
    List<PurchaseArrivalResponse> arrivals(UUID uuid);
}
