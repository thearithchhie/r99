package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.module.product.dto.response.ProductImageResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductWithImagesResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface ProductImageService {

    List<ProductImageResponse> uploadImages(UUID productUuid, List<MultipartFile> files);

    ProductWithImagesResponse findImages(UUID productUuid);

    void deleteImage(UUID productUuid, Long imageId);
}
