package com.r99.r99_shop_api.module.stock.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@JsonPropertyOrder({"id", "product_id", "product_code", "product_name", "delta", "reason", "reference_id", "note", "created_by", "created_at"})
public class StockMovementResponse {

    private Long id;

    @JsonProperty("product_id")
    private Long productId;

    @JsonProperty("product_code")
    private String productCode;

    @JsonProperty("product_name")
    private String productName;

    private Integer delta;
    private String reason;

    @JsonProperty("reference_id")
    private String referenceId;

    private String note;

    @JsonProperty("created_by")
    private Long createdBy;

    @JsonProperty("created_at")
    private Instant createdAt;
}
