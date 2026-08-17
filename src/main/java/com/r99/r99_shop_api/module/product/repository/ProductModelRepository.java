package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.ProductModel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ProductModelRepository extends JpaRepository<ProductModel, Long> {
    Optional<ProductModel> findByUuid(UUID uuid);
    Optional<ProductModel> findByUuidAndDeletedAtIsNull(UUID uuid);
}
