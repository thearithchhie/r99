package com.r99.r99_shop_api.module.user.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.user.dto.request.UserCreateRequest;
import com.r99.r99_shop_api.module.user.dto.request.UserUpdateRequest;
import com.r99.r99_shop_api.module.user.dto.response.UserResponse;
import com.r99.r99_shop_api.module.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import com.r99.r99_shop_api.common.util.PageableUtil;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.springframework.security.core.Authentication;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> me(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.success(userService.findMe(authentication.getName())));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<UserResponse>>> list(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(userService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/{uuid}")
    public ResponseEntity<ApiResponse<UserResponse>> findOne(@PathVariable UUID uuid) {
        return ResponseEntity.ok(ApiResponse.success(userService.findOne(uuid)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> create(@Valid @RequestBody UserCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(userService.create(request)));
    }

    @PatchMapping("/{uuid}")
    public ResponseEntity<ApiResponse<UserResponse>> update(
            @PathVariable UUID uuid,
            @Valid @RequestBody UserUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(userService.updateOne(uuid, request)));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> delete(@PathVariable UUID uuid) {
        userService.deleteOne(uuid);
        return ResponseEntity.noContent().build();
    }
}