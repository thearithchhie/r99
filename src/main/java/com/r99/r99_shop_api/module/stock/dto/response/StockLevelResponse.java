package com.r99.r99_shop_api.module.stock.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@JsonPropertyOrder({"id", "product_id", "product_code", "product_name", "quantity", "updated_at"})
public class StockLevelResponse {

    private Long id;

    @JsonProperty("product_id")
    private Long productId;

    @JsonProperty("product_code")
    private String productCode;

    @JsonProperty("product_name")
    private String productName;

    private Integer quantity;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
