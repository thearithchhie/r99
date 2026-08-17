package com.r99.r99_shop_api.common.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
public abstract class AuditBase {

    @CreatedDate
    @Column(nullable = false, updatable = false)
    @JsonProperty("created_at")
    private Instant createdAt;

    @CreatedBy
    @Column(updatable = false)
    @JsonProperty("created_by")
    private String createdBy;

    @LastModifiedDate
    @Column(nullable = false)
    @JsonProperty("updated_at")
    private Instant updatedAt;

    @LastModifiedBy
    @JsonProperty("updated_by")
    private String updatedBy;

    @Column
    @JsonProperty("deleted_at")
    private Instant deletedAt;

    @Column
    @JsonProperty("deleted_by")
    private String deletedBy;
}
