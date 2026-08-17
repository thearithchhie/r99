package com.r99.r99_shop_api.module.auth.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.module.auth.dto.AuthResponse;
import com.r99.r99_shop_api.module.auth.dto.LoginRequest;
import com.r99.r99_shop_api.module.auth.dto.RegisterRequest;
import com.r99.r99_shop_api.module.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.register(request)));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.login(request)));
    }
}
