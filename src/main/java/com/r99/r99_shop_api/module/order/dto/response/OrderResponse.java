package com.r99.r99_shop_api.module.order.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import com.r99.r99_shop_api.module.order.entity.PageSource;
import com.r99.r99_shop_api.module.order.entity.PaymentMethod;
import com.r99.r99_shop_api.module.order.entity.PaymentType;
import com.r99.r99_shop_api.module.order.entity.ReturnReason;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({
        "id", "uuid", "status", "return_reason",
        "customer_id", "customer_name", "customer_phone",
        "staff_id", "staff_name", "page_source",
        "payment_type", "payment_method", "is_promotion",
        "subtotal", "delivery_fee", "total_amount",
        "items", "note", "created_at", "updated_at"
})
public class OrderResponse {

    private Long id;
    private UUID uuid;
    private OrderStatus status;

    @JsonProperty("return_reason")
    private ReturnReason returnReason;

    @JsonProperty("customer_id")
    private Long customerId;

    @JsonProperty("customer_name")
    private String customerName;

    @JsonProperty("customer_phone")
    private String customerPhone;

    @JsonProperty("staff_id")
    private Long staffId;

    @JsonProperty("staff_name")
    private String staffName;

    @JsonProperty("page_source")
    private PageSource pageSource;

    @JsonProperty("payment_type")
    private PaymentType paymentType;

    @JsonProperty("payment_method")
    private PaymentMethod paymentMethod;

    @JsonProperty("is_promotion")
    private Boolean isPromotion;

    private BigDecimal subtotal;

    @JsonProperty("delivery_fee")
    private BigDecimal deliveryFee;

    @JsonProperty("total_amount")
    private BigDecimal totalAmount;

    private List<OrderItemResponse> items;
    private String note;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
