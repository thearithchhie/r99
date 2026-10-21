package com.r99.r99_shop_api.module.expense.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseCategoryResponse;
import com.r99.r99_shop_api.module.expense.service.ExpenseCategoryService;
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
@RequestMapping("/api/v1/expense-categories")
@RequiredArgsConstructor
public class ExpenseCategoryController {

    private final ExpenseCategoryService expenseCategoryService;

    @GetMapping
    @PreAuthorize("@perm.can('" + Perm.Module.EXPENSE_CATEGORY + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<PagedResponse<ExpenseCategoryResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                expenseCategoryService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.EXPENSE_CATEGORY + "', '" + Perm.Action.READ + "')")
    public ResponseEntity<ApiResponse<ExpenseCategoryResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(expenseCategoryService.findOne(uuid)));
    }

    @PostMapping
    @PreAuthorize("@perm.can('" + Perm.Module.EXPENSE_CATEGORY + "', '" + Perm.Action.CREATE + "')")
    public ResponseEntity<ApiResponse<ExpenseCategoryResponse>> create(
            @Valid @RequestBody ExpenseCategoryCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(expenseCategoryService.create(request)));
    }

    @PutMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.EXPENSE_CATEGORY + "', '" + Perm.Action.UPDATE + "')")
    public ResponseEntity<ApiResponse<ExpenseCategoryResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody ExpenseCategoryUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(expenseCategoryService.update(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    @PreAuthorize("@perm.can('" + Perm.Module.EXPENSE_CATEGORY + "', '" + Perm.Action.DELETE + "')")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        expenseCategoryService.delete(uuid);
        return ResponseEntity.noContent().build();
    }
}
