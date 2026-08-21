package com.r99.r99_shop_api.module.role.repository;

import com.r99.r99_shop_api.module.role.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByUuid(UUID uuid);

    boolean existsByName(String name);

    @Query("SELECT COUNT(u) FROM User u JOIN u.roles r WHERE r.id = :roleId")
    long countUsersByRoleId(@Param("roleId") Long roleId);

    @Query("SELECT COUNT(p) FROM Role r JOIN r.permissions p WHERE r.id = :roleId")
    long countPermissionsByRoleId(@Param("roleId") Long roleId);
}
