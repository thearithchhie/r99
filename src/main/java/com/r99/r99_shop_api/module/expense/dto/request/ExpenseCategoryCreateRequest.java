package com.r99.r99_shop_api.module.expense.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExpenseCategoryCreateRequest {

    @NotBlank
    @Size(max = 100)
    private String name;

    private String description;
}
