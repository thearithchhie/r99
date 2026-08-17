package com.r99.r99_shop_api.module.auth.service;

import com.r99.r99_shop_api.module.auth.dto.AuthResponse;
import com.r99.r99_shop_api.module.auth.dto.LoginRequest;
import com.r99.r99_shop_api.module.auth.dto.RegisterRequest;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);
}
