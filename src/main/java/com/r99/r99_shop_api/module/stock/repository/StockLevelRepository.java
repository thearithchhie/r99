package com.r99.r99_shop_api.module.stock.repository;

import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StockLevelRepository extends JpaRepository<StockLevel, Long> {

    @EntityGraph(attributePaths = {"product"})
    Page<StockLevel> findAll(Pageable pageable);

    Optional<StockLevel> findByProductId(Long productId);
}
