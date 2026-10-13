package com.r99.r99_shop_api.module.customer.dto.response;

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
        "id", "uuid", "name", "phone", "address", "province", "facebook_name",
        "total_orders", "completed_orders", "total_paid", "net_spent",
        "pending_orders", "cancelled_orders", "refunded",
        "note", "created_at", "updated_at"
})
public class CustomerDetailResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String phone;
    private String address;
    private String province;

    @JsonProperty("facebook_name")
    private String facebookName;

    @JsonProperty("total_orders")
    private Long totalOrders;

    @JsonProperty("completed_orders")
    private Long completedOrders;

    @JsonProperty("total_paid")
    private BigDecimal totalPaid;

    @JsonProperty("net_spent")
    private BigDecimal netSpent;

    @JsonProperty("pending_orders")
    private Long pendingOrders;

    @JsonProperty("cancelled_orders")
    private Long cancelledOrders;

    private BigDecimal refunded;

    private String note;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
