package com.r99.r99_shop_api.module.purchase.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseCreateRequest;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseReceiveRequest;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseArrivalResponse;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseResponse;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseStatus;
import com.r99.r99_shop_api.module.purchase.service.PurchaseService;

import java.util.List;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import com.r99.r99_shop_api.common.security.Perm;

@RestController
@RequestMapping("/api/v1/purchases")
@RequiredArgsConstructor
public class PurchaseController {

    private final PurchaseService purchaseService;

    @GetMapping
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<PurchaseResponse>>> list(
            @RequestParam(required = false) PurchaseStatus status,
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                purchaseService.findAll(status, PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.findOne(uuid)));
    }

    @PostMapping
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.CREATE + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> create(
            @Valid @RequestBody PurchaseCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(purchaseService.create(request)));
    }

    @PutMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody PurchaseCreateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.update(uuid, request)));
    }

    @PostMapping("/{uuid}/confirm")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> confirm(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.confirm(uuid)));
    }

    @PostMapping("/{uuid}/receive")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> receive(
            @PathVariable UUID uuid,
            @Valid @RequestBody PurchaseReceiveRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.receive(uuid, request)));
    }

    @PostMapping("/{uuid}/cancel")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<PurchaseResponse>> cancel(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.cancel(uuid)));
    }

    @GetMapping("/{uuid}/arrivals")
    @PreAuthorize("@perm.can('" + Perm.Module.PURCHASE + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<List<PurchaseArrivalResponse>>> arrivals(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(purchaseService.arrivals(uuid)));
    }
}
