package com.r99.r99_shop_api.module.customer.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerCreateRequest;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerUpdateRequest;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface CustomerService {

    PagedResponse<CustomerResponse> findAll(Pageable pageable);

    CustomerResponse findOne(UUID uuid);

    List<CustomerResponse> search(String q, int size);

    CustomerResponse create(CustomerCreateRequest request);

    CustomerResponse update(UUID uuid, CustomerUpdateRequest request);

    void delete(UUID uuid);
}
