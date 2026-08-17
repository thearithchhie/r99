package com.r99.r99_shop_api.module.role.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RoleCreateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    private String description;
}
