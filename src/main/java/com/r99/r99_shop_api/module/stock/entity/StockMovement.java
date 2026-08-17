package com.r99.r99_shop_api.module.stock.entity;

import com.r99.r99_shop_api.module.product.entity.Product;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;

@Entity
@Table(name = "stock_movements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false)
    private Integer delta;

    @Column(nullable = false, length = 50)
    private String reason;

    @Column(name = "reference_id")
    private String referenceId;

    @Column(columnDefinition = "text")
    private String note;

    @Column(name = "created_by")
    private Long createdBy;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
