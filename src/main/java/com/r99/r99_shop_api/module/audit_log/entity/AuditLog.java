package com.r99.r99_shop_api.module.audit_log.entity;

import com.r99.r99_shop_api.module.auth.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;

@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(nullable = false)
    private String context;

    @Column(columnDefinition = "text", nullable = false)
    private String description;

    @Column(name = "user_agent", columnDefinition = "text", nullable = false)
    private String userAgent;

    @Column(nullable = false)
    private String operator;

    @Column(nullable = false, length = 45)
    private String ip;

    @Column(name = "status_id", nullable = false)
    @Builder.Default
    private Short statusId = 1;

    @Column(name = "priority", nullable = false)
    @Builder.Default
    private Integer priority = 1;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "updated_by")
    private Long updatedBy;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    @Column(name = "deleted_by")
    private Long deletedBy;
}
