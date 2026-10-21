package com.r99.r99_shop_api.module.order.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.order.dto.request.OrderCreateRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderPartialReturnRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderStatusUpdateRequest;
import com.r99.r99_shop_api.module.order.dto.response.OrderResponse;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import com.r99.r99_shop_api.module.order.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import com.r99.r99_shop_api.common.security.Perm;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    @PreAuthorize("@perm.can('" + Perm.Module.ORDER + "', '" + Perm.Action.READ + "')")
    public ApiResponse<PagedResponse<OrderResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) OrderStatus status) {
        return ApiResponse.success(orderService.findAll(status, PageRequest.of(page, size, Sort.by("createdAt").descending())));
    }

    @GetMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.ORDER + "', '" + Perm.Action.READ + "')")
    public ApiResponse<OrderResponse> get(@PathVariable UUID uuid) {
        return ApiResponse.success(orderService.findOne(uuid));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@perm.can('" + Perm.Module.ORDER + "', '" + Perm.Action.CREATE + "')")
    public ApiResponse<OrderResponse> create(@Valid @RequestBody OrderCreateRequest request) {
        return ApiResponse.success(orderService.create(request));
    }

    @PatchMapping("/{uuid}/status")
    @PreAuthorize("@perm.can('" + Perm.Module.ORDER + "', '" + Perm.Action.UPDATE + "')")
    public ApiResponse<OrderResponse> updateStatus(
            @PathVariable UUID uuid,
            @Valid @RequestBody OrderStatusUpdateRequest request) {
        return ApiResponse.success(orderService.updateStatus(uuid, request));
    }

    @PatchMapping("/{uuid}/partial-return")
    @PreAuthorize("@perm.can('" + Perm.Module.ORDER + "', '" + Perm.Action.UPDATE + "')")
    public ApiResponse<OrderResponse> partialReturn(
            @PathVariable UUID uuid,
            @Valid @RequestBody OrderPartialReturnRequest request) {
        return ApiResponse.success(orderService.partialReturn(uuid, request));
    }
}
