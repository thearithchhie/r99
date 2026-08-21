package com.r99.r99_shop_api.module.payroll.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.payroll.dto.request.PayrollCreateRequest;
import com.r99.r99_shop_api.module.payroll.dto.response.PayrollResponse;
import com.r99.r99_shop_api.module.payroll.service.PayrollService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payrolls")
@RequiredArgsConstructor
public class PayrollController {

    private final PayrollService payrollService;

    @GetMapping
    public ApiResponse<PagedResponse<PayrollResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(payrollService.findAll(PageRequest.of(page, size, Sort.by("createdAt").descending())));
    }

    @GetMapping("/{uuid}")
    public ApiResponse<PayrollResponse> get(@PathVariable UUID uuid) {
        return ApiResponse.success(payrollService.findOne(uuid));
    }

    @PostMapping("/generate")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<PayrollResponse> generate(@Valid @RequestBody PayrollCreateRequest request) {
        return ApiResponse.success(payrollService.generate(request));
    }

    @PatchMapping("/{uuid}/paid")
    public ApiResponse<PayrollResponse> markPaid(@PathVariable UUID uuid) {
        return ApiResponse.success(payrollService.markPaid(uuid));
    }
}
