package com.r99.r99_shop_api.module.expense.dto.request;

import com.r99.r99_shop_api.module.expense.entity.ExpenseCategoryStatus;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExpenseCategoryUpdateRequest {

    @Size(max = 100)
    private String name;

    private String description;

    private ExpenseCategoryStatus status;
}
