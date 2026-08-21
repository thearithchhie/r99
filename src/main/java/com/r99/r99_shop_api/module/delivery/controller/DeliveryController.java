package com.r99.r99_shop_api.module.delivery.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryCreateRequest;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryStatusUpdateRequest;
import com.r99.r99_shop_api.module.delivery.dto.response.DeliveryResponse;
import com.r99.r99_shop_api.module.delivery.service.DeliveryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/deliveries")
@RequiredArgsConstructor
public class DeliveryController {

    private final DeliveryService deliveryService;

    @GetMapping
    public ApiResponse<PagedResponse<DeliveryResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(deliveryService.findAll(PageRequest.of(page, size, Sort.by("createdAt").descending())));
    }

    @GetMapping("/{uuid}")
    public ApiResponse<DeliveryResponse> get(@PathVariable UUID uuid) {
        return ApiResponse.success(deliveryService.findOne(uuid));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<DeliveryResponse> create(@Valid @RequestBody DeliveryCreateRequest request) {
        return ApiResponse.success(deliveryService.create(request));
    }

    @PatchMapping("/{uuid}/status")
    public ApiResponse<DeliveryResponse> updateStatus(
            @PathVariable UUID uuid,
            @Valid @RequestBody DeliveryStatusUpdateRequest request) {
        return ApiResponse.success(deliveryService.updateStatus(uuid, request));
    }
}
