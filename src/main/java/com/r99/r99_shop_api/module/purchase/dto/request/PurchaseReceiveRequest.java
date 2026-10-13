package com.r99.r99_shop_api.module.purchase.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class PurchaseReceiveRequest {

    @NotEmpty
    @Valid
    private List<PurchaseReceiveItemRequest> items;

    private String note;
}
