package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@JsonPropertyOrder({"id", "size", "color", "created_at", "updated_at"})
public class ModelVariantResponse {

    private Long id;
    private String size;
    private String color;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
