package com.r99.r99_shop_api.module.product.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.product.dto.request.ProductCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductUpdateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductSearchResponse;
import com.r99.r99_shop_api.module.product.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import com.r99.r99_shop_api.common.security.Perm;

@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @PreAuthorize("@perm.can('" + Perm.Module.PRODUCT + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<ProductResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                productService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<ProductSearchResponse>>> search(
            @RequestParam(defaultValue = "") String q,
            @RequestParam(defaultValue = "10") int size
    ) {
        List<ProductSearchResponse> results = productService.search(q, size);
        String message = results.isEmpty() ? "No products found" : "Success";
        return ResponseEntity.ok(ApiResponse.success(results, message));
    }

    @GetMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.PRODUCT + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<ProductResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(productService.findOne(uuid)));
    }

    @PostMapping
    @PreAuthorize("@perm.can('" + Perm.Module.PRODUCT + "', '" + Perm.Action.CREATE + "')")
    public ResponseEntity<ApiResponse<ProductResponse>> create(
            @Valid @RequestBody ProductCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(productService.create(request)));
    }

    @PatchMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.PRODUCT + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<ProductResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody ProductUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(productService.updateOne(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.PRODUCT + "', '" + Perm.Action.DELETE + "')")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        productService.deleteOne(uuid);
        return ResponseEntity.noContent().build();
    }
}
