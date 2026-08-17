package com.r99.r99_shop_api.module.role.repository;

import com.r99.r99_shop_api.module.role.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByUuid(UUID uuid);

    boolean existsByName(String name);
}
