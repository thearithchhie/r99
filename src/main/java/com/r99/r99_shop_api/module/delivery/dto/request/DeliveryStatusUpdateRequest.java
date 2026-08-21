package com.r99.r99_shop_api.module.delivery.dto.request;

import com.r99.r99_shop_api.module.delivery.entity.DeliveryStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DeliveryStatusUpdateRequest {

    @NotNull
    private DeliveryStatus status;

    private String note;
}
