package com.r99.r99_shop_api.module.user.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.user.dto.request.UserCreateRequest;
import com.r99.r99_shop_api.module.user.dto.request.UserUpdateRequest;
import com.r99.r99_shop_api.module.user.dto.response.UserResponse;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface UserService {

    PagedResponse<UserResponse> findAll(Pageable pageable);

    UserResponse findOne(UUID uuid);

    UserResponse findMe(String phone);

    UserResponse create(UserCreateRequest request);

    UserResponse updateOne(UUID uuid, UserUpdateRequest request);

    void deleteOne(UUID uuid);
}