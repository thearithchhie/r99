package com.r99.r99_shop_api.module.purchase.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"product_uuid", "product_name", "product_code", "quantity_received", "arrived_at"})
public class PurchaseArrivalResponse {

    @JsonProperty("product_uuid")
    private UUID productUuid;

    @JsonProperty("product_name")
    private String productName;

    @JsonProperty("product_code")
    private String productCode;

    @JsonProperty("quantity_received")
    private Integer quantityReceived;

    @JsonProperty("arrived_at")
    private Instant arrivedAt;
}
