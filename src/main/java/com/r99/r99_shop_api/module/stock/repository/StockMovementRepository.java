package com.r99.r99_shop_api.module.stock.repository;

import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {

    @EntityGraph(attributePaths = {"product"})
    Page<StockMovement> findAll(Pageable pageable);
}
