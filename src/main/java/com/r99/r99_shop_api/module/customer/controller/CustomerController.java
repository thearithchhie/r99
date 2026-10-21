package com.r99.r99_shop_api.module.customer.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerCreateRequest;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerUpdateRequest;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerDetailResponse;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerResponse;
import com.r99.r99_shop_api.module.customer.service.CustomerService;
import com.r99.r99_shop_api.module.delivery.dto.response.DeliveryResponse;
import com.r99.r99_shop_api.module.delivery.service.DeliveryService;
import com.r99.r99_shop_api.module.order.dto.response.OrderResponse;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import com.r99.r99_shop_api.module.order.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
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
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;
    private final OrderService orderService;
    private final DeliveryService deliveryService;

    @GetMapping
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<CustomerResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                customerService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<CustomerResponse>>> search(
            @RequestParam(defaultValue = "") String q,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ResponseEntity.ok(ApiResponse.success(customerService.search(q, size)));
    }

    @GetMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<CustomerDetailResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(customerService.findOne(uuid)));
    }

    @PostMapping
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.CREATE + "')")
    public ResponseEntity<ApiResponse<CustomerResponse>> create(
            @Valid @RequestBody CustomerCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(customerService.create(request)));
    }

    @PatchMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<CustomerResponse>> update(
            @PathVariable UUID uuid,
            @RequestBody CustomerUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(customerService.update(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.DELETE + "')")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        customerService.delete(uuid);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{uuid}/orders")
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<OrderResponse>>> orderHistory(
            @PathVariable UUID uuid,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) OrderStatus status
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                orderService.findAllByCustomer(uuid, status,
                        PageRequest.of(page, size, Sort.by("createdAt").descending()))));
    }

    @GetMapping("/{uuid}/deliveries")
    @PreAuthorize("@perm.can('" + Perm.Module.CUSTOMER + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<DeliveryResponse>>> deliveryHistory(
            @PathVariable UUID uuid,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                deliveryService.findAllByCustomer(uuid,
                        PageRequest.of(page, size, Sort.by("createdAt").descending()))));
    }
}
