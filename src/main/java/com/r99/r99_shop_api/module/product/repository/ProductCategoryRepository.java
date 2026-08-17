package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductCategoryRepository extends JpaRepository<ProductCategory, Long> {
    boolean existsByName(String name);
}
