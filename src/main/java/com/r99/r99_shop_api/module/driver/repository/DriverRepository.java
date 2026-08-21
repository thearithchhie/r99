package com.r99.r99_shop_api.module.driver.repository;

import com.r99.r99_shop_api.module.driver.entity.Driver;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface DriverRepository extends JpaRepository<Driver, Long> {

    Page<Driver> findAllByDeletedAtIsNull(Pageable pageable);

    Optional<Driver> findByUuidAndDeletedAtIsNull(UUID uuid);
}
