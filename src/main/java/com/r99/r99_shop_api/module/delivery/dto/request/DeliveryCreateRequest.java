package com.r99.r99_shop_api.module.delivery.dto.request;

import com.r99.r99_shop_api.module.delivery.entity.DeliveryPartnerType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
public class DeliveryCreateRequest {

    @NotNull
    private UUID orderUuid;

    private UUID driverUuid;

    @NotNull
    private DeliveryPartnerType partnerType;

    @NotNull
    @DecimalMin("0.00")
    private BigDecimal deliveryCost;

    private String note;
}
