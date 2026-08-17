package com.r99.r99_shop_api.module.audit_log.repository;

import com.r99.r99_shop_api.module.audit_log.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}
