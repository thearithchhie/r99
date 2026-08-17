package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.module.product.dto.request.ProductCategoryCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductCategoryResponse;

import java.util.List;

public interface ProductCategoryService {

    List<ProductCategoryResponse> findAll();

    ProductCategoryResponse create(ProductCategoryCreateRequest request);
}
