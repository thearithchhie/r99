package com.r99.r99_shop_api.module.expense.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseResponse;
import com.r99.r99_shop_api.module.expense.entity.Expense;
import com.r99.r99_shop_api.module.expense.entity.ExpenseCategory;
import com.r99.r99_shop_api.module.expense.entity.ExpenseCategoryStatus;
import com.r99.r99_shop_api.module.expense.entity.PaymentMethod;
import com.r99.r99_shop_api.module.expense.repository.ExpenseCategoryRepository;
import com.r99.r99_shop_api.module.expense.repository.ExpenseRepository;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final ExpenseCategoryRepository categoryRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<ExpenseResponse> findAll(UUID categoryUuid, PaymentMethod paymentMethod,
                                                   LocalDate dateFrom, LocalDate dateTo,
                                                   String search, Pageable pageable) {
        Specification<Expense> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.isNull(root.get("deletedAt")));

            if (categoryUuid != null) {
                Join<Object, Object> category = root.join("category");
                predicates.add(cb.equal(category.get("uuid"), categoryUuid));
            }
            if (paymentMethod != null) {
                predicates.add(cb.equal(root.get("paymentMethod"), paymentMethod));
            }
            if (dateFrom != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("expenseDate"), dateFrom));
            }
            if (dateTo != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("expenseDate"), dateTo));
            }
            if (search != null && !search.isBlank()) {
                String pattern = "%" + search.toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("description")), pattern),
                        cb.like(cb.lower(root.get("referenceNumber")), pattern)
                ));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return PagedResponse.of(
                expenseRepository.findAll(spec, pageable).map(this::toResponse),
                "expenses");
    }

    @Override
    @Transactional(readOnly = true)
    public ExpenseResponse findOne(UUID uuid) {
        return toResponse(findByUuid(uuid));
    }

    @Override
    @Transactional
    public ExpenseResponse create(ExpenseCreateRequest request) {
        ExpenseCategory category = findActiveCategory(request.getCategoryUuid());
        Expense saved = expenseRepository.save(Expense.builder()
                .category(category)
                .amount(request.getAmount())
                .description(request.getDescription())
                .expenseDate(request.getExpenseDate())
                .paymentMethod(request.getPaymentMethod())
                .referenceNumber(request.getReferenceNumber())
                .build());
        return toResponse(saved);
    }

    @Override
    @Transactional
    public ExpenseResponse update(UUID uuid, ExpenseUpdateRequest request) {
        Expense expense = findByUuid(uuid);
        if (request.getCategoryUuid() != null) {
            expense.setCategory(findActiveCategory(request.getCategoryUuid()));
        }
        if (request.getAmount() != null)          expense.setAmount(request.getAmount());
        if (request.getDescription() != null)     expense.setDescription(request.getDescription());
        if (request.getExpenseDate() != null)     expense.setExpenseDate(request.getExpenseDate());
        if (request.getPaymentMethod() != null)   expense.setPaymentMethod(request.getPaymentMethod());
        if (request.getReferenceNumber() != null) expense.setReferenceNumber(request.getReferenceNumber());
        return toResponse(expenseRepository.save(expense));
    }

    @Override
    @Transactional
    public void delete(UUID uuid) {
        Expense expense = findByUuid(uuid);
        expense.setDeletedAt(Instant.now());
        expenseRepository.save(expense);
    }

    private ExpenseCategory findActiveCategory(UUID uuid) {
        ExpenseCategory category = categoryRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Expense category not found"));
        if (category.getStatus() != ExpenseCategoryStatus.ACTIVE) {
            throw new AppException("Expense category is not active");
        }
        return category;
    }

    private Expense findByUuid(UUID uuid) {
        return expenseRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Expense not found"));
    }

    private ExpenseResponse toResponse(Expense e) {
        return ExpenseResponse.builder()
                .id(e.getId())
                .uuid(e.getUuid())
                .categoryUuid(e.getCategory().getUuid())
                .categoryName(e.getCategory().getName())
                .amount(e.getAmount())
                .description(e.getDescription())
                .expenseDate(e.getExpenseDate())
                .paymentMethod(e.getPaymentMethod())
                .referenceNumber(e.getReferenceNumber())
                .createdAt(e.getCreatedAt())
                .updatedAt(e.getUpdatedAt())
                .build();
    }
}
