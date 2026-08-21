package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({
        "uuid", "code", "name", "status", "current_stock",
        "variant_size", "variant_color", "model_name",
        "price", "images"
})
public class ProductWithImagesResponse {

    private UUID uuid;
    private String code;
    private String name;
    private String status;

    @JsonProperty("current_stock")
    private Integer currentStock;

    @JsonProperty("variant_size")
    private String variantSize;

    @JsonProperty("variant_color")
    private String variantColor;

    @JsonProperty("model_name")
    private String modelName;

    private BigDecimal price;

    private List<ProductImageResponse> images;
}
