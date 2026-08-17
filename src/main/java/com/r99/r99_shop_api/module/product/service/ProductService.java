package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.product.dto.request.ProductCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductUpdateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductSearchResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ProductService {

    PagedResponse<ProductResponse> findAll(Pageable pageable);

    ProductResponse findOne(UUID uuid);

    ProductResponse create(ProductCreateRequest request);

    ProductResponse updateOne(UUID uuid, ProductUpdateRequest request);

    void deleteOne(UUID uuid);

    List<ProductSearchResponse> search(String q, int size);
}
