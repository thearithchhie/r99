package com.r99.r99_shop_api.module.expense.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryCreateRequest;
import com.r99.r99_shop_api.module.expense.dto.request.ExpenseCategoryUpdateRequest;
import com.r99.r99_shop_api.module.expense.dto.response.ExpenseCategoryResponse;
import com.r99.r99_shop_api.module.expense.entity.ExpenseCategory;
import com.r99.r99_shop_api.module.expense.repository.ExpenseCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ExpenseCategoryServiceImpl implements ExpenseCategoryService {

    private final ExpenseCategoryRepository categoryRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<ExpenseCategoryResponse> findAll(Pageable pageable) {
        return PagedResponse.of(
                categoryRepository.findAllByDeletedAtIsNull(pageable).map(this::toResponse),
                "expense_categories");
    }

    @Override
    @Transactional(readOnly = true)
    public ExpenseCategoryResponse findOne(UUID uuid) {
        return toResponse(findByUuid(uuid));
    }

    @Override
    @Transactional
    public ExpenseCategoryResponse create(ExpenseCategoryCreateRequest request) {
        if (categoryRepository.existsByNameAndDeletedAtIsNull(request.getName())) {
            throw new AppException("Expense category name already exists");
        }
        ExpenseCategory saved = categoryRepository.save(ExpenseCategory.builder()
                .name(request.getName())
                .description(request.getDescription())
                .build());
        return toResponse(saved);
    }

    @Override
    @Transactional
    public ExpenseCategoryResponse update(UUID uuid, ExpenseCategoryUpdateRequest request) {
        ExpenseCategory category = findByUuid(uuid);
        if (request.getName() != null) {
            if (!request.getName().equals(category.getName())
                    && categoryRepository.existsByNameAndDeletedAtIsNull(request.getName())) {
                throw new AppException("Expense category name already exists");
            }
            category.setName(request.getName());
        }
        if (request.getDescription() != null) category.setDescription(request.getDescription());
        if (request.getStatus() != null)      category.setStatus(request.getStatus());
        return toResponse(categoryRepository.save(category));
    }

    @Override
    @Transactional
    public void delete(UUID uuid) {
        ExpenseCategory category = findByUuid(uuid);
        category.setDeletedAt(Instant.now());
        categoryRepository.save(category);
    }

    private ExpenseCategory findByUuid(UUID uuid) {
        return categoryRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Expense category not found"));
    }

    private ExpenseCategoryResponse toResponse(ExpenseCategory c) {
        return ExpenseCategoryResponse.builder()
                .id(c.getId())
                .uuid(c.getUuid())
                .name(c.getName())
                .description(c.getDescription())
                .status(c.getStatus())
                .createdAt(c.getCreatedAt())
                .updatedAt(c.getUpdatedAt())
                .build();
    }
}
