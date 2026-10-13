package com.r99.r99_shop_api.module.supplier.repository;

import com.r99.r99_shop_api.module.supplier.entity.Supplier;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface SupplierRepository extends JpaRepository<Supplier, Long> {

    Optional<Supplier> findByUuidAndDeletedAtIsNull(UUID uuid);

    boolean existsByNameAndDeletedAtIsNull(String name);

    @Query("""
            SELECT s FROM Supplier s
            WHERE s.deletedAt IS NULL
              AND (:status IS NULL OR s.status = :status)
              AND (:search IS NULL OR :search = '' OR
                   LOWER(s.name)          LIKE LOWER(CONCAT('%', :search, '%')) OR
                   LOWER(s.phone)         LIKE LOWER(CONCAT('%', :search, '%')) OR
                   LOWER(s.email)         LIKE LOWER(CONCAT('%', :search, '%')) OR
                   LOWER(s.contactPerson) LIKE LOWER(CONCAT('%', :search, '%')))
            """)
    Page<Supplier> search(@Param("search") String search,
                          @Param("status") SupplierStatus status,
                          Pageable pageable);
}
