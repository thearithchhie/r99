package com.r99.r99_shop_api.module.expense.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseResponse;
import com.r99.r99_shop_api.module.expense.entity.PaymentMethod;
import com.r99.r99_shop_api.module.expense.service.ExpenseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<ExpenseResponse>>> list(
            @RequestParam(required = false) UUID category,
            @RequestParam(required = false) PaymentMethod payment_method,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date_from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date_to,
            @RequestParam(required = false) String search,
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                expenseService.findAll(category, payment_method, date_from, date_to, search,
                        PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<ExpenseResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(expenseService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ExpenseResponse>> create(
            @Valid @RequestBody ExpenseCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(expenseService.create(request)));
    }

    @PutMapping("/{uuid}")
    @PatchMapping("/{uuid}")
    public ResponseEntity<ApiResponse<ExpenseResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody ExpenseUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(expenseService.update(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        expenseService.delete(uuid);
        return ResponseEntity.noContent().build();
    }
}
