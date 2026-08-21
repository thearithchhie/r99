package com.r99.r99_shop_api.module.delivery.repository;

import com.r99.r99_shop_api.module.delivery.entity.Delivery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {

    @EntityGraph(attributePaths = {"order", "order.customer", "driver"})
    @Query("SELECT d FROM Delivery d WHERE d.deletedAt IS NULL")
    Page<Delivery> findAllByDeletedAtIsNull(Pageable pageable);

    @EntityGraph(attributePaths = {"order", "order.customer", "order.items", "order.items.product", "driver"})
    @Query("SELECT d FROM Delivery d WHERE d.uuid = :uuid AND d.deletedAt IS NULL")
    Optional<Delivery> findByUuidAndDeletedAtIsNull(@Param("uuid") UUID uuid);

    Optional<Delivery> findByOrderId(Long orderId);
}
