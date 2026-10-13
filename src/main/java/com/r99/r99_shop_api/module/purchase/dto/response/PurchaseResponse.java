package com.r99.r99_shop_api.module.purchase.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseStatus;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({
        "id", "uuid", "order_number", "status",
        "supplier_uuid", "supplier_name",
        "subtotal", "discount_amount", "tax_amount", "shipping_cost", "total_amount",
        "items", "note", "ordered_at", "created_at", "updated_at"
})
public class PurchaseResponse {

    private Long id;
    private UUID uuid;

    @JsonProperty("order_number")
    private String orderNumber;

    private PurchaseStatus status;

    @JsonProperty("supplier_uuid")
    private UUID supplierUuid;

    @JsonProperty("supplier_name")
    private String supplierName;

    private BigDecimal subtotal;

    @JsonProperty("discount_amount")
    private BigDecimal discountAmount;

    @JsonProperty("tax_amount")
    private BigDecimal taxAmount;

    @JsonProperty("shipping_cost")
    private BigDecimal shippingCost;

    @JsonProperty("total_amount")
    private BigDecimal totalAmount;

    private List<PurchaseItemResponse> items;

    private String note;

    @JsonProperty("ordered_at")
    private Instant orderedAt;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
