package com.r99.r99_shop_api.module.commission.repository;

import com.r99.r99_shop_api.module.commission.entity.CommissionStatus;
import com.r99.r99_shop_api.module.commission.entity.DeliveryCommission;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeliveryCommissionRepository extends JpaRepository<DeliveryCommission, Long> {

    Optional<DeliveryCommission> findByDeliveryId(Long deliveryId);

    List<DeliveryCommission> findByDriverIdAndStatus(Long driverId, CommissionStatus status);

    List<DeliveryCommission> findByStatus(CommissionStatus status);

    @EntityGraph(attributePaths = {"driver", "delivery"})
    @Query("SELECT dc FROM DeliveryCommission dc WHERE dc.status = :status AND dc.createdAt >= :from AND dc.createdAt <= :to")
    List<DeliveryCommission> findByStatusAndCreatedAtBetween(
            @Param("status") CommissionStatus status,
            @Param("from") Instant from,
            @Param("to") Instant to);

    @EntityGraph(attributePaths = {"driver", "delivery"})
    @Query("SELECT dc FROM DeliveryCommission dc WHERE dc.status = :status AND dc.createdAt >= :from AND dc.createdAt <= :to AND dc.driver.uuid IN :uuids")
    List<DeliveryCommission> findByStatusAndCreatedAtBetweenAndDriverUuidIn(
            @Param("status") CommissionStatus status,
            @Param("from") Instant from,
            @Param("to") Instant to,
            @Param("uuids") List<UUID> uuids);
}
