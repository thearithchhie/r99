package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.module.product.dto.request.ProductCategoryCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductCategoryResponse;
import com.r99.r99_shop_api.module.product.entity.ProductCategory;
import com.r99.r99_shop_api.module.product.repository.ProductCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductCategoryServiceImpl implements ProductCategoryService {

    private final ProductCategoryRepository categoryRepository;

    @Override
    public List<ProductCategoryResponse> findAll() {
        return categoryRepository.findAll(Sort.by(Sort.Direction.ASC, "name"))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public ProductCategoryResponse create(ProductCategoryCreateRequest request) {
        if (categoryRepository.existsByName(request.getName())) {
            throw new AppException("Category name already exists");
        }
        ProductCategory saved = categoryRepository.save(
                ProductCategory.builder().name(request.getName()).build());
        return toResponse(saved);
    }

    private ProductCategoryResponse toResponse(ProductCategory c) {
        return ProductCategoryResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .createdAt(c.getCreatedAt())
                .updatedAt(c.getUpdatedAt())
                .build();
    }
}
