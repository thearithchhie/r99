package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({
        "id", "uuid", "code", "name", "sku",
        "price", "cost", "tone", "status", "current_stock",
        "variant_id", "variant_size", "variant_color",
        "model_id", "model_name",
        "category_id", "category_name",
        "line_id", "line_name",
        "created_at", "created_by", "updated_at", "updated_by"
})
public class ProductResponse {

    private Long id;
    private UUID uuid;
    private String code;
    private String name;
    private String sku;
    private BigDecimal price;
    private BigDecimal cost;
    private Short tone;
    private String status;

    @JsonProperty("current_stock")
    private Integer currentStock;

    @JsonProperty("variant_id")
    private Long variantId;

    @JsonProperty("variant_size")
    private String variantSize;

    @JsonProperty("variant_color")
    private String variantColor;

    @JsonProperty("model_id")
    private Long modelId;

    @JsonProperty("model_name")
    private String modelName;

    @JsonProperty("category_id")
    private Long categoryId;

    @JsonProperty("category_name")
    private String categoryName;

    @JsonProperty("line_id")
    private Long lineId;

    @JsonProperty("line_name")
    private String lineName;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("created_by")
    private String createdBy;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    @JsonProperty("updated_by")
    private String updatedBy;
}
