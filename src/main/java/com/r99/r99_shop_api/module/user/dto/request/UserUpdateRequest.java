package com.r99.r99_shop_api.module.user.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserUpdateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Phone is required")
    private String phone;
}
