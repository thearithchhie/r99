package com.r99.r99_shop_api.module.role.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import com.r99.r99_shop_api.module.permission.entity.Permission;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role extends AuditBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, updatable = false)
    @Builder.Default
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false)
    private String name;

    @Column
    private String description;

    @Column
    @Builder.Default
    private String status = "ACTIVE";

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "role_permission",
            joinColumns = @JoinColumn(name = "role_id"),
            inverseJoinColumns = @JoinColumn(name = "permission_id")
    )
    @Builder.Default
    private List<Permission> permissions = List.of();
}
