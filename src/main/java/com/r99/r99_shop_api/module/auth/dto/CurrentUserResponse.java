package com.r99.r99_shop_api.module.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"uuid", "name", "phone", "status", "role", "permissions"})
public class CurrentUserResponse {

    private UUID uuid;
    private String name;
    private String phone;
    private String status;
    private String role;

    @JsonProperty("permissions")
    private Map<String, List<String>> permissions;
}
