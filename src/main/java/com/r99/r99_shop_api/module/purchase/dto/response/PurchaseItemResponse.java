package com.r99.r99_shop_api.module.purchase.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"uuid", "product_uuid", "product_name", "product_code", "quantity", "received_quantity", "remaining_quantity", "cost_price", "discount_amount", "subtotal"})
public class PurchaseItemResponse {

    private UUID uuid;

    @JsonProperty("product_uuid")
    private UUID productUuid;

    @JsonProperty("product_name")
    private String productName;

    @JsonProperty("product_code")
    private String productCode;

    private Integer quantity;

    @JsonProperty("received_quantity")
    private Integer receivedQuantity;

    @JsonProperty("remaining_quantity")
    private Integer remainingQuantity;

    @JsonProperty("cost_price")
    private BigDecimal costPrice;

    @JsonProperty("discount_amount")
    private BigDecimal discountAmount;

    private BigDecimal subtotal;
}
