package com.r99.r99_shop_api.module.expense.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.r99.r99_shop_api.module.expense.entity.PaymentMethod;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
public class ExpenseUpdateRequest {

    @JsonProperty("category_uuid")
    private UUID categoryUuid;

    @Positive
    private BigDecimal amount;

    private String description;

    @JsonProperty("expense_date")
    private LocalDate expenseDate;

    @JsonProperty("payment_method")
    private PaymentMethod paymentMethod;

    @JsonProperty("reference_number")
    private String referenceNumber;
}
