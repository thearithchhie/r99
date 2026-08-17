package com.r99.r99_shop_api.module.auth.entity;

import com.r99.r99_shop_api.common.entity.AuditBase;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends AuditBase implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, updatable = false)
    @Builder.Default
    private UUID uuid = UUID.randomUUID();

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String phone;

    @Column(nullable = false)
    private String password;

    @Column
    @Builder.Default
    private String status = "active";

    @Override
    public String getUsername() {
        return phone;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }
}
