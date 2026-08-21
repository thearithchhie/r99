package com.r99.r99_shop_api.module.payroll.repository;

import com.r99.r99_shop_api.module.payroll.entity.Payroll;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface PayrollRepository extends JpaRepository<Payroll, Long> {

    Page<Payroll> findAllByOrderByCreatedAtDesc(Pageable pageable);

    @EntityGraph(attributePaths = {"items", "items.staff", "items.driver"})
    @Query("SELECT p FROM Payroll p WHERE p.uuid = :uuid")
    Optional<Payroll> findByUuidWithItems(@Param("uuid") UUID uuid);
}
