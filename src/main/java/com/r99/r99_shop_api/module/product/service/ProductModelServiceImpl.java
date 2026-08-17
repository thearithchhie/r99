package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.module.product.dto.request.ModelVariantCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductModelCreateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ModelVariantResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelDetailResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductModelResponse;
import com.r99.r99_shop_api.module.product.entity.ModelVariant;
import com.r99.r99_shop_api.module.product.entity.ProductModel;
import com.r99.r99_shop_api.module.product.repository.ModelVariantRepository;
import com.r99.r99_shop_api.module.product.repository.ProductModelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductModelServiceImpl implements ProductModelService {

    private final ProductModelRepository modelRepository;
    private final ModelVariantRepository variantRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ProductModelResponse> findAll() {
        return modelRepository.findAll(Sort.by(Sort.Direction.ASC, "name"))
                .stream()
                .map(this::toModelResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ProductModelDetailResponse findOne(UUID uuid) {
        ProductModel model = modelRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Product model not found"));
        List<ModelVariantResponse> variants = variantRepository.findByModelId(model.getId())
                .stream()
                .map(this::toVariantResponse)
                .toList();
        return ProductModelDetailResponse.builder()
                .id(model.getId())
                .uuid(model.getUuid())
                .name(model.getName())
                .description(model.getDescription())
                .variants(variants)
                .createdAt(model.getCreatedAt())
                .updatedAt(model.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional
    public ProductModelResponse create(ProductModelCreateRequest request) {
        ProductModel saved = modelRepository.save(
                ProductModel.builder()
                        .name(request.getName())
                        .description(request.getDescription())
                        .build());
        return toModelResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ModelVariantResponse> findVariants(Long modelId) {
        if (!modelRepository.existsById(modelId)) {
            throw new AppException("Product model not found");
        }
        return variantRepository.findByModelId(modelId)
                .stream()
                .map(this::toVariantResponse)
                .toList();
    }

    @Override
    @Transactional
    public ModelVariantResponse createVariant(Long modelId, ModelVariantCreateRequest request) {
        ProductModel model = modelRepository.findById(modelId)
                .orElseThrow(() -> new AppException("Product model not found"));

        boolean duplicate = variantRepository.findByModelId(modelId).stream()
                .anyMatch(v -> v.getSize().equalsIgnoreCase(request.getSize())
                            && v.getColor().equalsIgnoreCase(request.getColor()));
        if (duplicate) {
            throw new AppException("Variant with this size and color already exists for this model");
        }

        ModelVariant saved = variantRepository.save(
                ModelVariant.builder()
                        .model(model)
                        .size(request.getSize())
                        .color(request.getColor())
                        .build());
        return toVariantResponse(saved);
    }

    private ProductModelResponse toModelResponse(ProductModel m) {
        return ProductModelResponse.builder()
                .id(m.getId())
                .uuid(m.getUuid())
                .name(m.getName())
                .description(m.getDescription())
                .createdAt(m.getCreatedAt())
                .updatedAt(m.getUpdatedAt())
                .build();
    }

    private ModelVariantResponse toVariantResponse(ModelVariant v) {
        return ModelVariantResponse.builder()
                .id(v.getId())
                .size(v.getSize())
                .color(v.getColor())
                .createdAt(v.getCreatedAt())
                .updatedAt(v.getUpdatedAt())
                .build();
    }
}
