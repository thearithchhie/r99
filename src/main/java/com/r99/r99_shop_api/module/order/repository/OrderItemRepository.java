package com.r99.r99_shop_api.module.order.repository;

import com.r99.r99_shop_api.module.order.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
}
