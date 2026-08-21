package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.module.media.entity.Media;
import com.r99.r99_shop_api.module.media.entity.StorageType;
import com.r99.r99_shop_api.module.media.repository.MediaRepository;
import com.r99.r99_shop_api.module.media.service.MinioService;
import com.r99.r99_shop_api.module.product.dto.response.ProductImageResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductWithImagesResponse;
import com.r99.r99_shop_api.module.product.entity.ModelVariant;
import com.r99.r99_shop_api.module.product.entity.Product;
import com.r99.r99_shop_api.module.product.entity.ProductImage;
import com.r99.r99_shop_api.module.product.repository.ProductImageRepository;
import com.r99.r99_shop_api.module.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductImageServiceImpl implements ProductImageService {

    private final ProductRepository productRepository;
    private final MediaRepository mediaRepository;
    private final ProductImageRepository productImageRepository;
    private final MinioService minioService;

    @Override
    @Transactional
    public List<ProductImageResponse> uploadImages(UUID productUuid, List<MultipartFile> files) {
        Product product = productRepository.findByUuidAndDeletedAtIsNull(productUuid)
                .orElseThrow(() -> new AppException("Product not found"));

        int currentCount = productImageRepository
                .findByProductIdAndDeletedAtIsNullOrderByPriorityAsc(product.getId()).size();

        List<ProductImageResponse> results = new ArrayList<>();

        for (int i = 0; i < files.size(); i++) {
            MultipartFile file = files.get(i);

            String fileUrl = minioService.upload(file, "products/" + productUuid);

            Media media = mediaRepository.save(Media.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .storageType(StorageType.MINIO)
                    .mimeType(file.getContentType())
                    .fileSize(file.getSize())
                    .build());

            ProductImage image = productImageRepository.save(ProductImage.builder()
                    .product(product)
                    .media(media)
                    .priority((short) (currentCount + i))
                    .build());

            results.add(toResponse(image));
        }

        return results;
    }

    @Override
    @Transactional(readOnly = true)
    public ProductWithImagesResponse findImages(UUID productUuid) {
        Product product = productRepository.findWithVariantAndStockByUuid(productUuid)
                .orElseThrow(() -> new AppException("Product not found"));

        ModelVariant variant = product.getVariant();

        List<ProductImageResponse> images = productImageRepository
                .findByProductIdAndDeletedAtIsNullOrderByPriorityAsc(product.getId())
                .stream()
                .map(this::toResponse)
                .toList();

        return ProductWithImagesResponse.builder()
                .uuid(product.getUuid())
                .code(product.getCode())
                .name(product.getName())
                .status(product.getStatus())
                .currentStock(product.getStockLevel() != null ? product.getStockLevel().getQuantity() : null)
                .variantSize(variant != null ? variant.getSize() : null)
                .variantColor(variant != null ? variant.getColor() : null)
                .modelName(variant != null && variant.getModel() != null ? variant.getModel().getName() : null)
                .price(product.getPrice())
                .images(images)
                .build();
    }

    @Override
    @Transactional
    public void deleteImage(UUID productUuid, Long imageId) {
        productRepository.findByUuidAndDeletedAtIsNull(productUuid)
                .orElseThrow(() -> new AppException("Product not found"));

        ProductImage image = productImageRepository.findById(imageId)
                .orElseThrow(() -> new AppException("Image not found"));

        image.setDeletedAt(Instant.now());
        productImageRepository.save(image);
    }

    private ProductImageResponse toResponse(ProductImage img) {
        Media m = img.getMedia();
        return ProductImageResponse.builder()
                .id(img.getId())
                .fileName(m.getFileName())
                .fileUrl(m.getFileUrl())
                .mimeType(m.getMimeType())
                .fileSize(m.getFileSize())
                .priority(img.getPriority())
                .createdAt(img.getCreatedAt())
                .build();
    }
}
