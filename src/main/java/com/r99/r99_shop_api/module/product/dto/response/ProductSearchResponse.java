package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"uuid", "code", "name", "variant_size", "variant_color", "current_stock"})
public class ProductSearchResponse {

    private UUID uuid;
    private String code;
    private String name;

    @JsonProperty("variant_size")
    private String variantSize;

    @JsonProperty("variant_color")
    private String variantColor;

    @JsonProperty("current_stock")
    private Integer currentStock;
}
