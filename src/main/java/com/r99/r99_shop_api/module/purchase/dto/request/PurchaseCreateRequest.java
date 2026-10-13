package com.r99.r99_shop_api.module.purchase.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class PurchaseCreateRequest {

    @NotNull
    @JsonProperty("supplier_uuid")
    private UUID supplierUuid;

    @NotEmpty
    @Valid
    private List<PurchaseCreateItemRequest> items;

    @PositiveOrZero
    @JsonProperty("discount_amount")
    private BigDecimal discountAmount;

    @PositiveOrZero
    @JsonProperty("tax_amount")
    private BigDecimal taxAmount;

    @PositiveOrZero
    @JsonProperty("shipping_cost")
    private BigDecimal shippingCost;

    private String note;
}
