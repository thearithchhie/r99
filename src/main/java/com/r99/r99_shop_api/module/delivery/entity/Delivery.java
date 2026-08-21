package com.r99.r99_shop_api.module.delivery.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import com.r99.r99_shop_api.module.driver.entity.Driver;
import com.r99.r99_shop_api.module.order.entity.Order;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "deliveries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Delivery extends AuditBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Builder.Default
    @Column(nullable = false, unique = true)
    private UUID uuid = UUID.randomUUID();

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id")
    private Driver driver;

    @Enumerated(EnumType.STRING)
    @Column(name = "partner_type", nullable = false, length = 20)
    private DeliveryPartnerType partnerType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private DeliveryStatus status = DeliveryStatus.PENDING;

    @Column(name = "delivery_cost", nullable = false, precision = 10, scale = 2)
    private BigDecimal deliveryCost;

    @Column(name = "commission_earned", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal commissionEarned = BigDecimal.ZERO;

    @Column(name = "commission_received_at")
    private Instant commissionReceivedAt;

    @Column(name = "recipient_name", nullable = false)
    private String recipientName;

    @Column(name = "recipient_phone", nullable = false, length = 50)
    private String recipientPhone;

    @Column(name = "recipient_address", nullable = false, columnDefinition = "text")
    private String recipientAddress;

    @Column(name = "delivered_at")
    private Instant deliveredAt;

    @Column(columnDefinition = "text")
    private String note;
}
