package com.r99.r99_shop_api.module.permission.repository;

import com.r99.r99_shop_api.module.permission.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PermissionRepository extends JpaRepository<Permission, Long> {

    Optional<Permission> findByUuid(UUID uuid);

    boolean existsByName(String name);

    List<Permission> findByUuidIn(List<UUID> uuids);
}
