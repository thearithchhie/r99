package com.r99.r99_shop_api.module.delivery.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryCreateRequest;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryStatusUpdateRequest;
import com.r99.r99_shop_api.module.delivery.dto.response.DeliveryResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface DeliveryService {

    PagedResponse<DeliveryResponse> findAll(Pageable pageable);

    DeliveryResponse findOne(UUID uuid);

    DeliveryResponse create(DeliveryCreateRequest request);

    DeliveryResponse updateStatus(UUID uuid, DeliveryStatusUpdateRequest request);
}
