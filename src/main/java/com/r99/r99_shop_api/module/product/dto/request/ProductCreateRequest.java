package com.r99.r99_shop_api.module.product.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class ProductCreateRequest {

    @NotBlank(message = "Code is required")
    private String code;

    @NotBlank(message = "Name is required")
    private String name;

    private String sku;

    @NotNull(message = "Variant ID is required")
    @JsonProperty("variant_id")
    private Long variantId;

    @JsonProperty("category_id")
    private Long categoryId;

    @JsonProperty("line_id")
    private Long lineId;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0", message = "Price must be >= 0")
    private BigDecimal price;

    @NotNull(message = "Cost is required")
    @DecimalMin(value = "0", message = "Cost must be >= 0")
    private BigDecimal cost;

    private Short tone;

    @NotNull(message = "Initial stock is required")
    @Min(value = 0, message = "Initial stock must be >= 0")
    @JsonProperty("initial_stock")
    private Integer initialStock;
}
