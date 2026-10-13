package com.r99.r99_shop_api.module.purchase.repository;

import com.r99.r99_shop_api.module.purchase.entity.PurchaseOrder;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import java.util.UUID;

public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {

    @EntityGraph(attributePaths = {"supplier"})
    Page<PurchaseOrder> findAllByDeletedAtIsNull(Pageable pageable);

    @EntityGraph(attributePaths = {"supplier"})
    Page<PurchaseOrder> findAllByStatusAndDeletedAtIsNull(PurchaseStatus status, Pageable pageable);

    @EntityGraph(attributePaths = {"supplier"})
    Page<PurchaseOrder> findAllBySupplier_UuidAndDeletedAtIsNull(UUID supplierUuid, Pageable pageable);

    @EntityGraph(attributePaths = {"supplier", "items", "items.product"})
    Optional<PurchaseOrder> findByUuidAndDeletedAtIsNull(UUID uuid);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM PurchaseOrder p WHERE p.uuid = :uuid AND p.deletedAt IS NULL")
    Optional<PurchaseOrder> findByUuidForUpdate(@Param("uuid") UUID uuid);

    @Query(value = "SELECT COUNT(*) FROM purchase_orders WHERE DATE(created_at) = CURRENT_DATE", nativeQuery = true)
    long countTodayOrders();
}
