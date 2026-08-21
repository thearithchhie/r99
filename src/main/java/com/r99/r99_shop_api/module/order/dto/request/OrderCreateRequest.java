package com.r99.r99_shop_api.module.order.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.r99.r99_shop_api.module.order.entity.PageSource;
import com.r99.r99_shop_api.module.order.entity.PaymentMethod;
import com.r99.r99_shop_api.module.order.entity.PaymentType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;
import java.util.UUID;

@Getter
public class OrderCreateRequest {

    @NotNull(message = "Customer UUID is required")
    @JsonProperty("customer_uuid")
    private UUID customerUuid;

    @JsonProperty("staff_uuid")
    private UUID staffUuid;

    @NotNull(message = "Page source is required")
    @JsonProperty("page_source")
    private PageSource pageSource;

    @NotNull(message = "Payment type is required")
    @JsonProperty("payment_type")
    private PaymentType paymentType;

    @JsonProperty("payment_method")
    private PaymentMethod paymentMethod;

    @JsonProperty("is_promotion")
    private Boolean isPromotion;

    @NotEmpty(message = "Order must have at least one item")
    @Valid
    private List<OrderItemRequest> items;

    private String note;
}
