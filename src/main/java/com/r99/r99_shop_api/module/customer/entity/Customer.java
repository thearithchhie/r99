package com.r99.r99_shop_api.module.customer.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "customers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Customer extends AuditBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Builder.Default
    @Column(nullable = false, unique = true)
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 50)
    private String phone;

    @Column(columnDefinition = "text")
    private String address;

    @Column(length = 100)
    private String province;

    @Column(name = "facebook_name")
    private String facebookName;

    @Column(columnDefinition = "text")
    private String note;
}
