package com.r99.r99_shop_api.module.order.repository;

import com.r99.r99_shop_api.module.order.entity.Order;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, Long> {

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByDeletedAtIsNull(Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff"})
    Page<Order> findAllByStatusAndDeletedAtIsNull(OrderStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"customer", "staff", "items", "items.product"})
    Optional<Order> findByUuidAndDeletedAtIsNull(UUID uuid);
}
