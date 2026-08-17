package com.r99.r99_shop_api.module.stock.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.UUID;

@Getter
public class StockMovementRequest {

    @NotNull(message = "Product UUID is required")
    @JsonProperty("product_uuid")
    private UUID productUuid;

    @NotNull(message = "Delta is required")
    private Integer delta;

    @NotBlank(message = "Reason is required")
    private String reason;

    @JsonProperty("reference_id")
    private String referenceId;

    private String note;
}
