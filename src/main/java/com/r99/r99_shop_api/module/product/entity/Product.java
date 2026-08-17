package com.r99.r99_shop_api.module.product.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import com.r99.r99_shop_api.module.product.entity.ModelVariant;
import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends AuditBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Builder.Default
    @Column(nullable = false, unique = true)
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @Column(nullable = false)
    private String name;

    @Column(length = 100)
    private String sku;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ProductCategory category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "line_id")
    private ProductLine line;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id")
    private ModelVariant variant;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cost;

    @Builder.Default
    @Column(nullable = false)
    private Short tone = 0;

    @Builder.Default
    @Column(nullable = false, length = 50)
    private String status = "in_stock";

    @OneToOne(mappedBy = "product", fetch = FetchType.LAZY)
    private StockLevel stockLevel;
}
