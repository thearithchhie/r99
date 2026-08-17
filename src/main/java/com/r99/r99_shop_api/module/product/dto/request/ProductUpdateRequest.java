package com.r99.r99_shop_api.module.product.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.DecimalMin;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class ProductUpdateRequest {

    private String name;
    private String sku;

    @JsonProperty("variant_id")
    private Long variantId;

    @JsonProperty("category_id")
    private Long categoryId;

    @JsonProperty("line_id")
    private Long lineId;

    @DecimalMin(value = "0", message = "Price must be >= 0")
    private BigDecimal price;

    @DecimalMin(value = "0", message = "Cost must be >= 0")
    private BigDecimal cost;

    private Short tone;
    private String status;
}
