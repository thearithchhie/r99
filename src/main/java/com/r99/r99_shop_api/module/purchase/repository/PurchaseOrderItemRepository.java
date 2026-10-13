package com.r99.r99_shop_api.module.purchase.repository;

import com.r99.r99_shop_api.module.purchase.entity.PurchaseOrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PurchaseOrderItemRepository extends JpaRepository<PurchaseOrderItem, Long> {

    Optional<PurchaseOrderItem> findByUuid(UUID uuid);
}
