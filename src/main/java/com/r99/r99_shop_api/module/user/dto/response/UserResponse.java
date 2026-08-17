package com.r99.r99_shop_api.module.user.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "phone", "status", "created_by", "created_at", "updated_at", "updated_by"})
public class UserResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String phone;
    private String status;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("created_by")
    private String createdBy;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    @JsonProperty("updated_by")
    private String updatedBy;
}
