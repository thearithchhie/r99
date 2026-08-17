package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.ModelVariant;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ModelVariantRepository extends JpaRepository<ModelVariant, Long> {

    @EntityGraph(attributePaths = {"model"})
    List<ModelVariant> findByModelId(Long modelId);

    @EntityGraph(attributePaths = {"model"})
    Optional<ModelVariant> findById(Long id);
}