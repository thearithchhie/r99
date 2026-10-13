package com.r99.r99_shop_api.module.purchase.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
public class PurchaseCreateItemRequest {

    @NotNull
    @JsonProperty("product_uuid")
    private UUID productUuid;

    @NotNull
    @Min(1)
    private Integer quantity;

    @NotNull
    @PositiveOrZero
    @JsonProperty("cost_price")
    private BigDecimal costPrice;

    @PositiveOrZero
    @JsonProperty("discount_amount")
    private BigDecimal discountAmount;
}
