package com.r99.r99_shop_api.module.driver.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.driver.dto.request.DriverCreateRequest;
import com.r99.r99_shop_api.module.driver.dto.response.DriverResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface DriverService {

    PagedResponse<DriverResponse> findAll(Pageable pageable);

    DriverResponse findOne(UUID uuid);

    DriverResponse create(DriverCreateRequest request);

    void delete(UUID uuid);
}
