package com.r99.r99_shop_api.module.order.repository;

import com.r99.r99_shop_api.module.order.entity.Order;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, Long> {

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByDeletedAtIsNull(Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByStatusAndDeletedAtIsNull(OrderStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByCustomer_UuidAndDeletedAtIsNull(UUID customerUuid, Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByCustomer_UuidAndStatusAndDeletedAtIsNull(UUID customerUuid, OrderStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff", "items", "items.product"})
    Optional<Order> findByUuidAndDeletedAtIsNull(UUID uuid);

    @Query(value = """
            SELECT
                COUNT(*)                                                                                    AS total_orders,
                SUM(CASE WHEN o.status = 'DELIVERED'                                  THEN 1 ELSE 0 END)   AS completed_orders,
                COALESCE(SUM(CASE WHEN o.status = 'DELIVERED'                         THEN o.total_amount ELSE 0 END), 0) AS total_paid,
                SUM(CASE WHEN o.status IN ('PENDING','CONFIRMED','DELIVERING')         THEN 1 ELSE 0 END)   AS pending_orders,
                SUM(CASE WHEN o.status = 'CANCELLED'                                  THEN 1 ELSE 0 END)   AS cancelled_orders,
                COALESCE(SUM(CASE WHEN o.status IN ('RETURNED','PARTIALLY_RETURNED')  THEN o.total_amount ELSE 0 END), 0) AS refunded
            FROM orders o
            JOIN customers c ON o.customer_id = c.id
            WHERE c.uuid = :customerUuid AND o.deleted_at IS NULL
            """, nativeQuery = true)
    List<Object[]> fetchCustomerStats(@Param("customerUuid") UUID customerUuid);
}
