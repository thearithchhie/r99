package com.r99.r99_shop_api.module.expense.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.expense.entity.ExpenseCategoryStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "description", "status", "created_at", "updated_at"})
public class ExpenseCategoryResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String description;
    private ExpenseCategoryStatus status;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
