package com.r99.r99_shop_api.module.product.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.module.product.dto.request.ModelVariantCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductModelCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ModelVariantResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelDetailResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelResponse;
import com.r99.r99_shop_api.module.product.service.ProductModelService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/product-models")
@RequiredArgsConstructor
public class ProductModelController {

    private final ProductModelService modelService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProductModelResponse>>> list() {
        return ResponseEntity.ok(ApiResponse.success(modelService.findAll()));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<ProductModelDetailResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(modelService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProductModelResponse>> create(
            @Valid @RequestBody ProductModelCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(modelService.create(request)));
    }

    @GetMapping("/{modelId}/variants")
    public ResponseEntity<ApiResponse<List<ModelVariantResponse>>> listVariants(
            @PathVariable Long modelId
    ) {
        return ResponseEntity.ok(ApiResponse.success(modelService.findVariants(modelId)));
    }

    @PostMapping("/{modelId}/variants")
    public ResponseEntity<ApiResponse<ModelVariantResponse>> createVariant(
            @PathVariable Long modelId,
            @Valid @RequestBody ModelVariantCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(modelService.createVariant(modelId, request)));
    }
}
