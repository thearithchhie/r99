package com.r99.r99_shop_api.module.order.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.order.dto.request.OrderCreateRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderPartialReturnRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderStatusUpdateRequest;
import com.r99.r99_shop_api.module.order.dto.response.OrderResponse;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface OrderService {

    PagedResponse<OrderResponse> findAll(OrderStatus status, Pageable pageable);

    OrderResponse findOne(UUID uuid);

    OrderResponse create(OrderCreateRequest request);

    OrderResponse updateStatus(UUID uuid, OrderStatusUpdateRequest request);

    OrderResponse partialReturn(UUID uuid, OrderPartialReturnRequest request);
}
