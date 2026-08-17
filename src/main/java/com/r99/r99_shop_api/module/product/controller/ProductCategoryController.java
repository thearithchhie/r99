package com.r99.r99_shop_api.module.product.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.module.product.dto.request.ProductCategoryCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductCategoryResponse;
import com.r99.r99_shop_api.module.product.service.ProductCategoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/product-categories")
@RequiredArgsConstructor
public class ProductCategoryController {

    private final ProductCategoryService categoryService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProductCategoryResponse>>> list() {
        return ResponseEntity.ok(ApiResponse.success(categoryService.findAll()));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProductCategoryResponse>> create(
            @Valid @RequestBody ProductCategoryCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(categoryService.create(request)));
    }
}
