package com.r99.r99_shop_api.module.payroll.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.payroll.dto.request.PayrollCreateRequest;
import com.r99.r99_shop_api.module.payroll.dto.response.PayrollResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface PayrollService {

    PagedResponse<PayrollResponse> findAll(Pageable pageable);

    PayrollResponse findOne(UUID uuid);

    PayrollResponse generate(PayrollCreateRequest request);

    PayrollResponse markPaid(UUID uuid);
}
