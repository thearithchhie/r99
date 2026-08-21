package com.r99.r99_shop_api.module.commission.repository;

import com.r99.r99_shop_api.module.commission.entity.CommissionStatus;
import com.r99.r99_shop_api.module.commission.entity.StaffCommission;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface StaffCommissionRepository extends JpaRepository<StaffCommission, Long> {

    Optional<StaffCommission> findByOrderId(Long orderId);

    List<StaffCommission> findByStaffIdAndStatus(Long staffId, CommissionStatus status);

    List<StaffCommission> findByStatus(CommissionStatus status);

    @EntityGraph(attributePaths = {"staff", "order"})
    @Query("SELECT sc FROM StaffCommission sc WHERE sc.status = :status AND sc.createdAt >= :from AND sc.createdAt <= :to")
    List<StaffCommission> findByStatusAndCreatedAtBetween(
            @Param("status") CommissionStatus status,
            @Param("from") Instant from,
            @Param("to") Instant to);

    @EntityGraph(attributePaths = {"staff", "order"})
    @Query("SELECT sc FROM StaffCommission sc WHERE sc.status = :status AND sc.createdAt >= :from AND sc.createdAt <= :to AND sc.staff.uuid IN :uuids")
    List<StaffCommission> findByStatusAndCreatedAtBetweenAndStaffUuidIn(
            @Param("status") CommissionStatus status,
            @Param("from") Instant from,
            @Param("to") Instant to,
            @Param("uuids") List<UUID> uuids);
}
