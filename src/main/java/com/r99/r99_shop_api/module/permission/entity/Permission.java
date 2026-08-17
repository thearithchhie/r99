package com.r99.r99_shop_api.module.permission.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "permissions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Permission extends AuditBase {

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
    private String module;

    @Column
    private String action;

    @Column
    @Builder.Default
    private String status = "ACTIVE";
}
