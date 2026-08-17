package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.module.product.dto.request.ProductLineCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductLineResponse;

import java.util.List;

public interface ProductLineService {

    List<ProductLineResponse> findAll();

    ProductLineResponse create(ProductLineCreateRequest request);
}
