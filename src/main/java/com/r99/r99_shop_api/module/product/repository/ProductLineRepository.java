package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.ProductLine;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductLineRepository extends JpaRepository<ProductLine, Long> {
    boolean existsByName(String name);
}
