package com.r99.r99_shop_api.module.expense.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseResponse;
import com.r99.r99_shop_api.module.expense.entity.PaymentMethod;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.UUID;

public interface ExpenseService {
    PagedResponse<ExpenseResponse> findAll(UUID categoryUuid, PaymentMethod paymentMethod,
                                           LocalDate dateFrom, LocalDate dateTo,
                                           String search, Pageable pageable);
    ExpenseResponse findOne(UUID uuid);
    ExpenseResponse create(ExpenseCreateRequest request);
    ExpenseResponse update(UUID uuid, ExpenseUpdateRequest request);
    void delete(UUID uuid);
}
