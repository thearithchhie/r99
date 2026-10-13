package com.r99.r99_shop_api.module.purchase.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class PurchaseReceiveItemRequest {

    @NotNull
    @JsonProperty("purchase_item_uuid")
    private UUID purchaseItemUuid;

    @NotNull
    @PositiveOrZero
    @JsonProperty("received_quantity")
    private Integer receivedQuantity;
}
