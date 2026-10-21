package com.r99.r99_shop_api.module.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuthResponse {

    @JsonProperty("access_token")
    private String accessToken;
}
