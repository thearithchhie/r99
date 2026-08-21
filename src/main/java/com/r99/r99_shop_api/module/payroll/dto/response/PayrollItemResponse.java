package com.r99.r99_shop_api.module.payroll.dto.response;

import com.r99.r99_shop_api.module.payroll.entity.RecipientType;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class PayrollItemResponse {

    private Long id;
    private RecipientType recipientType;

    private Long recipientId;
    private String recipientName;

    private Integer commissionCount;
    private BigDecimal totalAmount;
}
