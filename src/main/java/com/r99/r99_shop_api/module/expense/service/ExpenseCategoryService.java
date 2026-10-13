package com.r99.r99_shop_api.module.expense.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseCategoryResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface ExpenseCategoryService {
    PagedResponse<ExpenseCategoryResponse> findAll(Pageable pageable);
    ExpenseCategoryResponse findOne(UUID uuid);
    ExpenseCategoryResponse create(ExpenseCategoryCreateRequest request);
    ExpenseCategoryResponse update(UUID uuid, ExpenseCategoryUpdateRequest request);
    void delete(UUID uuid);
}
