package com.r99.r99_shop_api.module.product.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class ModelVariantCreateRequest {

    @NotBlank(message = "Size is required")
    private String size;

    @NotBlank(message = "Color is required")
    private String color;
}
