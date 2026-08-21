package com.r99.r99_shop_api.module.payroll.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
public class PayrollCreateRequest {

    @NotNull
    @JsonProperty("week_start")
    private LocalDate weekStart;

    @NotNull
    @JsonProperty("week_end")
    private LocalDate weekEnd;

    @JsonProperty("staff_uuids")
    private List<UUID> staffUuids;

    @JsonProperty("driver_uuids")
    private List<UUID> driverUuids;

    private String note;
}
