package com.r99.r99_shop_api.module.payroll.dto.response;

import com.r99.r99_shop_api.module.payroll.entity.PayrollStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class PayrollResponse {

    private Long id;
    private UUID uuid;

    private LocalDate weekStart;
    private LocalDate weekEnd;

    private BigDecimal totalAmount;
    private PayrollStatus status;

    private Instant paidAt;
    private String note;

    private List<PayrollItemResponse> items;

    private Instant createdAt;
    private Instant updatedAt;
}
