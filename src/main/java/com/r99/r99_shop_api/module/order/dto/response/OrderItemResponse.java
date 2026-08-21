package com.r99.r99_shop_api.module.order.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@JsonPropertyOrder({"product_id", "product_code", "product_name", "quantity", "unit_price", "unit_cost", "subtotal"})
public class OrderItemResponse {

    @JsonProperty("product_id")
    private Long productId;

    @JsonProperty("product_code")
    private String productCode;

    @JsonProperty("product_name")
    private String productName;

    private Integer quantity;

    @JsonProperty("unit_price")
    private BigDecimal unitPrice;

    @JsonProperty("unit_cost")
    private BigDecimal unitCost;

    private BigDecimal subtotal;
}
