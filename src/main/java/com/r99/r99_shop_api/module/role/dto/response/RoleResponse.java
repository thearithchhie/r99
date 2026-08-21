package com.r99.r99_shop_api.module.role.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "description", "user_count", "permission_count", "status", "created_by", "created_at", "updated_at", "updated_by"})
public class RoleResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String description;

    @JsonProperty("user_count")
    private Long userCount;

    @JsonProperty("permission_count")
    private Long permissionCount;

    private String status;

    @JsonProperty("created_by")
    private String createdBy;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    @JsonProperty("updated_by")
    private String updatedBy;
}
