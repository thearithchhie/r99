package com.r99.r99_shop_api.module.product.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductImageResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductWithImagesResponse;
import com.r99.r99_shop_api.module.product.service.ProductImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/products/{uuid}/images")
@RequiredArgsConstructor
public class ProductImageController {

    private final ProductImageService productImageService;

    @GetMapping
    public ResponseEntity<ApiResponse<ProductWithImagesResponse>> list(
            @PathVariable UUID uuid
    ) {
        return ResponseEntity.ok(ApiResponse.success(productImageService.findImages(uuid)));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<List<ProductImageResponse>>> upload(
            @PathVariable UUID uuid,
            @RequestPart("files") List<MultipartFile> files
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(productImageService.uploadImages(uuid, files)));
    }

    @DeleteMapping("/{imageId}")
    public ResponseEntity<Void> delete(
            @PathVariable UUID uuid,
            @PathVariable Long imageId
    ) {
        productImageService.deleteImage(uuid, imageId);
        return ResponseEntity.noContent().build();
    }
}
