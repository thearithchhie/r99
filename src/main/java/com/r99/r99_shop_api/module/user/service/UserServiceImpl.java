package com.r99.r99_shop_api.module.user.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.service.AuditLogService;
import com.r99.r99_shop_api.module.auth.entity.User;
import com.r99.r99_shop_api.module.auth.repository.UserRepository;
import com.r99.r99_shop_api.module.user.dto.request.UserCreateRequest;
import com.r99.r99_shop_api.module.user.dto.request.UserUpdateRequest;
import com.r99.r99_shop_api.module.user.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuditLogService auditLogService;

    @Override
    public PagedResponse<UserResponse> findAll(Pageable pageable) {
        Page<UserResponse> page = userRepository.findAllByDeletedAtIsNull(pageable).map(this::toResponse);
        return PagedResponse.of(page, "users");
    }

    @Override
    public UserResponse findOne(UUID uuid) {
        User user = userRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Data not found"));
        return toResponse(user);
    }

    @Override
    public UserResponse findMe(String phone) {
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new AppException("User not found"));
        return toResponse(user);
    }

    @Override
    public UserResponse create(UserCreateRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new AppException("Phone already registered");
        }
        User user = User.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .build();
        User saved = userRepository.save(user);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Create User")
                .description(String.format("User '%s' (phone: %s) has been created successfully", saved.getName(), saved.getPhone()))
                .build());

        return toResponse(saved);
    }

    @Override
    public UserResponse updateOne(UUID uuid, UserUpdateRequest request) {
        User user = userRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Data not found"));
        if (user.getDeletedAt() != null) {
            throw new AppException("Data not found");
        }
        if (!user.getPhone().equals(request.getPhone()) && userRepository.existsByPhone(request.getPhone())) {
            throw new AppException("Phone already registered");
        }

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Update User")
                .description(String.format("User '%s' updated: name '%s' → '%s', phone '%s' → '%s'",
                        user.getUuid(), user.getName(), request.getName(), user.getPhone(), request.getPhone()))
                .build());

        user.setName(request.getName());
        user.setPhone(request.getPhone());
        return toResponse(userRepository.save(user));
    }

    @Override
    public void deleteOne(UUID uuid) {
        User user = userRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Data not found"));
        if (user.getDeletedAt() != null) {
            throw new AppException("Data not found");
        }
        String deletedBy = SecurityContextHolder.getContext().getAuthentication().getName();
        user.setDeletedAt(Instant.now());
        user.setDeletedBy(deletedBy);
        userRepository.save(user);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Delete User")
                .description(String.format("User '%s' (phone: %s) has been deleted successfully", user.getName(), user.getPhone()))
                .build());
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .uuid(user.getUuid())
                .name(user.getName())
                .phone(user.getPhone())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .createdBy(user.getCreatedBy())
                .updatedAt(user.getUpdatedAt())
                .updatedBy(user.getUpdatedBy())
                .build();
    }
}
