package com.r99.r99_shop_api.module.product.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.module.product.dto.request.ProductLineCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductLineResponse;
import com.r99.r99_shop_api.module.product.service.ProductLineService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/product-lines")
@RequiredArgsConstructor
public class ProductLineController {

    private final ProductLineService lineService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProductLineResponse>>> list() {
        return ResponseEntity.ok(ApiResponse.success(lineService.findAll()));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProductLineResponse>> create(
            @Valid @RequestBody ProductLineCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(lineService.create(request)));
    }
}
