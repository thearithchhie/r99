package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@JsonPropertyOrder({"id", "name", "created_at", "updated_at"})
public class ProductLineResponse {

    private Long id;
    private String name;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
