package com.r99.r99_shop_api.module.supplier.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@JsonPropertyOrder({"id", "uuid", "name", "phone", "email", "address", "contact_person", "status", "created_at", "updated_at"})
public class SupplierResponse {

    private Long id;
    private UUID uuid;
    private String name;
    private String phone;
    private String email;
    private String address;

    @JsonProperty("contact_person")
    private String contactPerson;

    private SupplierStatus status;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
