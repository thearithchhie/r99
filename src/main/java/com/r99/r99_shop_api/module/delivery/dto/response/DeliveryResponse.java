package com.r99.r99_shop_api.module.delivery.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.delivery.entity.DeliveryPartnerType;
import com.r99.r99_shop_api.module.delivery.entity.DeliveryStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@JsonPropertyOrder({
        "id", "uuid", "order_uuid",
        "recipient_name", "recipient_phone", "recipient_address",
        "driver_id", "driver_name", "driver_phone",
        "partner_type", "status",
        "delivery_cost", "commission_earned", "commission_received_at",
        "delivered_at", "note", "created_at", "updated_at"
})
public class DeliveryResponse {

    private Long id;
    private UUID uuid;

    @JsonProperty("order_uuid")
    private UUID orderUuid;

    @JsonProperty("recipient_name")
    private String recipientName;

    @JsonProperty("recipient_phone")
    private String recipientPhone;

    @JsonProperty("recipient_address")
    private String recipientAddress;

    @JsonProperty("driver_id")
    private Long driverId;

    @JsonProperty("driver_name")
    private String driverName;

    @JsonProperty("driver_phone")
    private String driverPhone;

    @JsonProperty("partner_type")
    private DeliveryPartnerType partnerType;

    private DeliveryStatus status;

    @JsonProperty("delivery_cost")
    private BigDecimal deliveryCost;

    @JsonProperty("commission_earned")
    private BigDecimal commissionEarned;

    @JsonProperty("commission_received_at")
    private Instant commissionReceivedAt;

    @JsonProperty("delivered_at")
    private Instant deliveredAt;

    private String note;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
