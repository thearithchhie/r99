package com.r99.r99_shop_api.module.role.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.permission.dto.response.PermissionResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "description", "status", "permissions", "created_by", "created_at", "updated_at", "updated_by"})
public class RoleDetailResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String description;
    private String status;
    private List<PermissionResponse> permissions;

    @JsonProperty("created_by")
    private String createdBy;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    @JsonProperty("updated_by")
    private String updatedBy;
}
