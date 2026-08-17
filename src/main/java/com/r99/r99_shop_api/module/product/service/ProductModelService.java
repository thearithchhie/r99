package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.module.product.dto.request.ModelVariantCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductModelCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ModelVariantResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelDetailResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelResponse;

import java.util.List;
import java.util.UUID;

public interface ProductModelService {

    List<ProductModelResponse> findAll();

    ProductModelDetailResponse findOne(UUID uuid);

    ProductModelResponse create(ProductModelCreateRequest request);

    List<ModelVariantResponse> findVariants(Long modelId);

    ModelVariantResponse createVariant(Long modelId, ModelVariantCreateRequest request);
}
