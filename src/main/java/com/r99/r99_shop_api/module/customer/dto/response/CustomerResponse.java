package com.r99.r99_shop_api.module.customer.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "phone", "address", "province", "facebook_name", "note", "created_at", "updated_at"})
public class CustomerResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String phone;
    private String address;
    private String province;

    @JsonProperty("facebook_name")
    private String facebookName;

    private String note;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
