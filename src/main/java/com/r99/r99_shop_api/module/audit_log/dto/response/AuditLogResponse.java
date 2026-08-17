package com.r99.r99_shop_api.module.audit_log.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@JsonPropertyOrder({"id", "user_id", "user_name", "context", "description", "user_agent", "operator", "ip", "status_id", "priority", "created_by", "created_at"})
public class AuditLogResponse {

    private Long id;

    @JsonProperty("user_id")
    private Long userId;

    @JsonProperty("user_name")
    private String userName;

    private String context;
    private String description;

    @JsonProperty("user_agent")
    private String userAgent;

    private String operator;
    private String ip;

    @JsonProperty("status_id")
    private Short statusId;

    private Integer priority;

    @JsonProperty("created_by")
    private Long createdBy;

    @JsonProperty("created_at")
    private Instant createdAt;
}
