package com.r99.r99_shop_api.module.permission.dto.response;

import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "description", "module", "action", "status"})
public class PermissionResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String description;
    private String module;
    private String action;
    private String status;
}
