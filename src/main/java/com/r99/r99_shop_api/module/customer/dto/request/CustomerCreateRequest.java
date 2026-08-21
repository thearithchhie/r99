package com.r99.r99_shop_api.module.customer.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class CustomerCreateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Phone is required")
    private String phone;

    private String address;
    private String province;

    @JsonProperty("facebook_name")
    private String facebookName;

    private String note;
}
