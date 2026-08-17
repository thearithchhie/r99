package com.r99.r99_shop_api.module.product.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class ProductModelCreateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    private String description;
}
