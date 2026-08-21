package com.r99.r99_shop_api.module.driver.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "phone", "note", "created_at", "updated_at"})
public class DriverResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String phone;
    private String note;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
