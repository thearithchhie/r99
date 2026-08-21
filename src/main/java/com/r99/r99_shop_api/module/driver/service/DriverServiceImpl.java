package com.r99.r99_shop_api.module.driver.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.driver.dto.request.DriverCreateRequest;
import com.r99.r99_shop_api.module.driver.dto.response.DriverResponse;
import com.r99.r99_shop_api.module.driver.entity.Driver;
import com.r99.r99_shop_api.module.driver.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DriverServiceImpl implements DriverService {

    private final DriverRepository driverRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<DriverResponse> findAll(Pageable pageable) {
        return PagedResponse.of(
                driverRepository.findAllByDeletedAtIsNull(pageable).map(this::toResponse),
                "drivers");
    }

    @Override
    @Transactional(readOnly = true)
    public DriverResponse findOne(UUID uuid) {
        return toResponse(driverRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Driver not found")));
    }

    @Override
    @Transactional
    public DriverResponse create(DriverCreateRequest request) {
        return toResponse(driverRepository.save(Driver.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .note(request.getNote())
                .build()));
    }

    @Override
    @Transactional
    public void delete(UUID uuid) {
        Driver driver = driverRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Driver not found"));
        driver.setDeletedAt(Instant.now());
        driverRepository.save(driver);
    }

    private DriverResponse toResponse(Driver d) {
        return DriverResponse.builder()
                .id(d.getId())
                .uuid(d.getUuid())
                .name(d.getName())
                .phone(d.getPhone())
                .note(d.getNote())
                .createdAt(d.getCreatedAt())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}
