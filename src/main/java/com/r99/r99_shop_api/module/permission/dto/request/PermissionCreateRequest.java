package com.r99.r99_shop_api.module.permission.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PermissionCreateRequest {

    @NotBlank(message = "Name is required")
    private String name;

    private String description;

    private String module;

    private String action;
}
