package com.r99.r99_shop_api.module.expense.repository;

import com.r99.r99_shop_api.module.expense.entity.ExpenseCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExpenseCategoryRepository extends JpaRepository<ExpenseCategory, Long> {

    Optional<ExpenseCategory> findByUuidAndDeletedAtIsNull(UUID uuid);

    boolean existsByNameAndDeletedAtIsNull(String name);

    Page<ExpenseCategory> findAllByDeletedAtIsNull(Pageable pageable);

    List<ExpenseCategory> findAllByStatusAndDeletedAtIsNull(
            com.r99.r99_shop_api.module.expense.entity.ExpenseCategoryStatus status);
}
