package com.r99.r99_shop_api.module.product.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "product_models")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductModel extends AuditBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Builder.Default
    @Column(nullable = false, unique = true)
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "text")
    private String description;
}
