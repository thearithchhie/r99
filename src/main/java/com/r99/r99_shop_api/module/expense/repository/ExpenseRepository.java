package com.r99.r99_shop_api.module.expense.repository;

import com.r99.r99_shop_api.module.expense.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.Optional;
import java.util.UUID;

public interface ExpenseRepository extends JpaRepository<Expense, Long>,
        JpaSpecificationExecutor<Expense> {

    Optional<Expense> findByUuidAndDeletedAtIsNull(UUID uuid);
}
