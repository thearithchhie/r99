package com.r99.r99_shop_api.module.product.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "description", "variants", "created_at", "updated_at"})
public class ProductModelDetailResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String description;
    private List<ModelVariantResponse> variants;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
