package com.r99.r99_shop_api.module.stock.repository;

import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {

    @EntityGraph(attributePaths = {"product"})
    Page<StockMovement> findAll(Pageable pageable);

    @EntityGraph(attributePaths = {"product"})
    List<StockMovement> findAllByReasonAndReferenceIdOrderByCreatedAtAsc(String reason, String referenceId);
}
