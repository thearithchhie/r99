package com.r99.r99_shop_api.module.auth.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.security.JwtUtil;
import com.r99.r99_shop_api.module.auth.dto.AuthResponse;
import com.r99.r99_shop_api.module.auth.dto.LoginRequest;
import com.r99.r99_shop_api.module.auth.dto.RegisterRequest;
import com.r99.r99_shop_api.module.auth.entity.User;
import com.r99.r99_shop_api.module.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new AppException("Phone already registered");
        }

        User user = User.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .build();

        userRepository.save(user);

        return new AuthResponse(jwtUtil.generateToken(user));
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getPhone(), request.getPassword())
        );

        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new AppException("User not found"));

        return new AuthResponse(jwtUtil.generateToken(user));
    }
}
