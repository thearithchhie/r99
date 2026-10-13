package com.r99.r99_shop_api.module.expense.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.expense.entity.PaymentMethod;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({
        "id", "uuid", "category_uuid", "category_name",
        "amount", "description", "expense_date",
        "payment_method", "reference_number", "created_at", "updated_at"
})
public class ExpenseResponse {

    private Long id;
    private UUID uuid;

    @JsonProperty("category_uuid")
    private UUID categoryUuid;

    @JsonProperty("category_name")
    private String categoryName;

    private BigDecimal amount;
    private String description;

    @JsonProperty("expense_date")
    private LocalDate expenseDate;

    @JsonProperty("payment_method")
    private PaymentMethod paymentMethod;

    @JsonProperty("reference_number")
    private String referenceNumber;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
