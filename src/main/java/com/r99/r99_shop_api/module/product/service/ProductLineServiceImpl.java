package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.module.product.dto.request.ProductLineCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductLineResponse;
import com.r99.r99_shop_api.module.product.entity.ProductLine;
import com.r99.r99_shop_api.module.product.repository.ProductLineRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductLineServiceImpl implements ProductLineService {

    private final ProductLineRepository lineRepository;

    @Override
    public List<ProductLineResponse> findAll() {
        return lineRepository.findAll(Sort.by(Sort.Direction.ASC, "name"))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public ProductLineResponse create(ProductLineCreateRequest request) {
        if (lineRepository.existsByName(request.getName())) {
            throw new AppException("Product line name already exists");
        }
        ProductLine saved = lineRepository.save(
                ProductLine.builder().name(request.getName()).build());
        return toResponse(saved);
    }

    private ProductLineResponse toResponse(ProductLine l) {
        return ProductLineResponse.builder()
                .id(l.getId())
                .name(l.getName())
                .createdAt(l.getCreatedAt())
                .updatedAt(l.getUpdatedAt())
                .build();
    }
}
