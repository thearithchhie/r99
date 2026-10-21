package com.r99.r99_shop_api.module.auth.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.security.JwtUtil;
import com.r99.r99_shop_api.module.auth.dto.AuthResponse;
import com.r99.r99_shop_api.module.auth.dto.CurrentUserResponse;
import com.r99.r99_shop_api.module.auth.dto.LoginRequest;
import com.r99.r99_shop_api.module.auth.dto.RegisterRequest;
import com.r99.r99_shop_api.module.auth.entity.User;
import com.r99.r99_shop_api.module.auth.repository.UserRepository;
import com.r99.r99_shop_api.module.permission.entity.Permission;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

        return toAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getPhone(), request.getPassword())
        );

        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new AppException("User not found"));

        return toAuthResponse(user);
    }

    @Override
    @Transactional(readOnly = true)
    public CurrentUserResponse currentUser(String phone) {
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new AppException("User not found"));

        Map<String, List<String>> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .collect(Collectors.groupingBy(
                        Permission::getModule,
                        Collectors.mapping(Permission::getAction, Collectors.toList())
                ));

        return CurrentUserResponse.builder()
                .uuid(user.getUuid())
                .name(user.getName())
                .phone(user.getPhone())
                .status(user.getStatus())
                .role(user.getPrimaryRole())
                .permissions(permissions)
                .build();
    }

    private AuthResponse toAuthResponse(User user) {
        return AuthResponse.builder()
                .accessToken(jwtUtil.generateToken(user))
                .build();
    }
}
