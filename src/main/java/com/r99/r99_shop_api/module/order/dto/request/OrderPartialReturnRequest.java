package com.r99.r99_shop_api.module.order.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.r99.r99_shop_api.module.order.entity.ReturnReason;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class OrderPartialReturnRequest {

    @NotNull(message = "Return reason is required")
    @JsonProperty("return_reason")
    private ReturnReason returnReason;

    @NotEmpty(message = "Items to return must not be empty")
    @Valid
    private List<OrderPartialReturnItemRequest> items;

    private String note;
}