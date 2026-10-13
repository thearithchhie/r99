package com.r99.r99_shop_api.module.supplier.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseResponse;
import com.r99.r99_shop_api.module.purchase.service.PurchaseService;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierCreateRequest;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierUpdateRequest;
import com.r99.r99_shop_api.module.supplier.dto.response.SupplierResponse;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import com.r99.r99_shop_api.module.supplier.service.SupplierService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;
    private final PurchaseService purchaseService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<SupplierResponse>>> list(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) SupplierStatus status,
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                supplierService.findAll(search, status, PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<SupplierResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(supplierService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<SupplierResponse>> create(
            @Valid @RequestBody SupplierCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(supplierService.create(request)));
    }

    @PutMapping("/{uuid}")
    public ResponseEntity<ApiResponse<SupplierResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody SupplierUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(supplierService.update(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        supplierService.delete(uuid);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{uuid}/purchases")
    public ResponseEntity<ApiResponse<PagedResponse<PurchaseResponse>>> purchases(
            @PathVariable UUID uuid,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                purchaseService.findAllBySupplier(uuid,
                        PageRequest.of(page, size, Sort.by("id").descending()))));
    }
}
