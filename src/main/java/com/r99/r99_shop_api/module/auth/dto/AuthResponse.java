package com.r99.r99_shop_api.module.auth.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class AuthResponse {

    private String token;
    private UUID uuid;
    private String name;
    private String phone;
    private String role;
}
