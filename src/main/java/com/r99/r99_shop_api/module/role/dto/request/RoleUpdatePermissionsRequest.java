package com.r99.r99_shop_api.module.role.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class RoleUpdatePermissionsRequest {

    @NotEmpty(message = "Permission is required")
    @JsonProperty("permission_uuids")
    private List<UUID> permissionUuids;
}
