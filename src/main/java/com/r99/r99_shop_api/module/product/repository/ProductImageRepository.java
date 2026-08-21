package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.ProductImage;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {

    @EntityGraph(attributePaths = {"media"})
    List<ProductImage> findByProductIdAndDeletedAtIsNullOrderByPriorityAsc(Long productId);
}
