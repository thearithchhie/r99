package com.r99.r99_shop_api.module.customer.repository;

import com.r99.r99_shop_api.module.customer.entity.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Page<Customer> findAllByDeletedAtIsNull(Pageable pageable);

    Optional<Customer> findByUuidAndDeletedAtIsNull(UUID uuid);

    @Query("""
            SELECT c FROM Customer c
            WHERE c.deletedAt IS NULL
              AND (LOWER(c.name)         LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(c.phone)        LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(c.facebookName) LIKE LOWER(CONCAT('%', :q, '%')))
            ORDER BY c.name ASC
            LIMIT :size
            """)
    java.util.List<Customer> searchByNameOrPhone(@Param("q") String q, @Param("size") int size);
}
