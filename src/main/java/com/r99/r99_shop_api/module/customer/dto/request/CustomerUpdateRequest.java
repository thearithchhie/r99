package com.r99.r99_shop_api.module.customer.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;

@Getter
public class CustomerUpdateRequest {

    private String name;
    private String phone;
    private String address;
    private String province;

    @JsonProperty("facebook_name")
    private String facebookName;

    private String note;
}
