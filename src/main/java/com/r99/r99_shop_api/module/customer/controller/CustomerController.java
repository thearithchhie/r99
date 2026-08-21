package com.r99.r99_shop_api.module.customer.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerCreateRequest;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerUpdateRequest;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerResponse;
import com.r99.r99_shop_api.module.customer.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<CustomerResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                customerService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<CustomerResponse>>> search(
            @RequestParam(defaultValue = "") String q,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ResponseEntity.ok(ApiResponse.success(customerService.search(q, size)));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<CustomerResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(customerService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CustomerResponse>> create(
            @Valid @RequestBody CustomerCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(customerService.create(request)));
    }

    @PatchMapping("/{uuid}")
    public ResponseEntity<ApiResponse<CustomerResponse>> update(
            @PathVariable UUID uuid,
            @RequestBody CustomerUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(customerService.update(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        customerService.delete(uuid);
        return ResponseEntity.noContent().build();
    }
}
