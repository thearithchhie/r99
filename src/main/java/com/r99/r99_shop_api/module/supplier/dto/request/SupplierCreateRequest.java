package com.r99.r99_shop_api.module.supplier.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SupplierCreateRequest {

    @NotBlank
    @Size(max = 150)
    private String name;

    @Size(max = 30)
    private String phone;

    @Email
    @Size(max = 150)
    private String email;

    private String address;

    @JsonProperty("contact_person")
    @Size(max = 150)
    private String contactPerson;
}
