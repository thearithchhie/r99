package com.r99.r99_shop_api.module.product.repository;

import com.r99.r99_shop_api.module.product.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, Long> {

    boolean existsByCode(String code);

    @EntityGraph(attributePaths = {"category", "line", "variant", "variant.model", "stockLevel"})
    Page<Product> findAllByDeletedAtIsNull(Pageable pageable);

    @EntityGraph(attributePaths = {"category", "line", "variant", "variant.model", "stockLevel"})
    Optional<Product> findByUuidAndDeletedAtIsNull(UUID uuid);

    Optional<Product> findByUuid(UUID uuid);

    @EntityGraph(attributePaths = {"variant", "variant.model", "stockLevel"})
    @Query("SELECT p FROM Product p WHERE p.uuid = :uuid AND p.deletedAt IS NULL")
    Optional<Product> findWithVariantAndStockByUuid(@Param("uuid") UUID uuid);

    @EntityGraph(attributePaths = {"variant", "stockLevel"})
    @Query("""
            SELECT p FROM Product p
            WHERE p.deletedAt IS NULL
              AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(p.code) LIKE LOWER(CONCAT('%', :q, '%')))
            ORDER BY p.name ASC
            LIMIT :size
            """)
    List<Product> searchByNameOrCode(@Param("q") String q, @Param("size") int size);
}
