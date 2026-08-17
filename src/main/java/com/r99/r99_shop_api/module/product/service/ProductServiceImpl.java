package com.r99.r99_shop_api.module.product.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.audit_log.dto.request.AuditLogCreateRequest;
import com.r99.r99_shop_api.module.audit_log.service.AuditLogService;
import com.r99.r99_shop_api.module.product.dto.request.ProductCreateRequest;
import com.r99.r99_shop_api.module.product.dto.request.ProductUpdateRequest;
import com.r99.r99_shop_api.module.product.dto.response.ProductResponse;
import com.r99.r99_shop_api.module.product.dto.response.ProductSearchResponse;
import com.r99.r99_shop_api.module.product.entity.ModelVariant;
import com.r99.r99_shop_api.module.product.entity.Product;
import com.r99.r99_shop_api.module.product.entity.ProductCategory;
import com.r99.r99_shop_api.module.product.entity.ProductLine;
import com.r99.r99_shop_api.module.product.entity.ProductModel;
import java.util.List;
import com.r99.r99_shop_api.module.product.repository.ModelVariantRepository;
import com.r99.r99_shop_api.module.product.repository.ProductCategoryRepository;
import com.r99.r99_shop_api.module.product.repository.ProductLineRepository;
import com.r99.r99_shop_api.module.product.repository.ProductRepository;
import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import com.r99.r99_shop_api.module.stock.repository.StockLevelRepository;
import com.r99.r99_shop_api.module.stock.repository.StockMovementRepository;
import com.r99.r99_shop_api.module.auth.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ModelVariantRepository variantRepository;
    private final ProductCategoryRepository categoryRepository;
    private final ProductLineRepository lineRepository;
    private final StockLevelRepository stockLevelRepository;
    private final StockMovementRepository stockMovementRepository;
    private final AuditLogService auditLogService;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<ProductResponse> findAll(Pageable pageable) {
        Page<ProductResponse> page = productRepository.findAllByDeletedAtIsNull(pageable)
                .map(this::toResponse);
        return PagedResponse.of(page, "products");
    }

    @Override
    @Transactional(readOnly = true)
    public ProductResponse findOne(UUID uuid) {
        Product product = productRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Product not found"));
        return toResponse(product);
    }

    @Override
    @Transactional
    public ProductResponse create(ProductCreateRequest request) {
        if (productRepository.existsByCode(request.getCode())) {
            throw new AppException("Product code already exists");
        }

        ModelVariant variant = variantRepository.findById(request.getVariantId())
                .orElseThrow(() -> new AppException("Variant not found"));
        ProductCategory category = resolveCategory(request.getCategoryId());
        ProductLine line = resolveLine(request.getLineId());

        Product product = Product.builder()
                .code(request.getCode())
                .name(request.getName())
                .sku(request.getSku())
                .variant(variant)
                .category(category)
                .line(line)
                .price(request.getPrice())
                .cost(request.getCost())
                .tone(request.getTone() != null ? request.getTone() : (short) 0)
                .build();

        Product saved = productRepository.save(product);

        StockLevel stockLevel = StockLevel.builder()
                .product(saved)
                .quantity(request.getInitialStock())
                .build();
        stockLevelRepository.save(stockLevel);

        if (request.getInitialStock() > 0) {
            StockMovement movement = StockMovement.builder()
                    .product(saved)
                    .delta(request.getInitialStock())
                    .reason("initial")
                    .createdBy(currentUserId())
                    .build();
            stockMovementRepository.save(movement);
        }

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Create Product")
                .description(String.format("Product '%s' (code: %s) created with initial stock %d",
                        saved.getName(), saved.getCode(), request.getInitialStock()))
                .build());

        return toResponse(productRepository.findByUuidAndDeletedAtIsNull(saved.getUuid())
                .orElse(saved));
    }

    @Override
    @Transactional
    public ProductResponse updateOne(UUID uuid, ProductUpdateRequest request) {
        Product product = productRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Product not found"));

        if (request.getName() != null) product.setName(request.getName());
        if (request.getSku() != null) product.setSku(request.getSku());
        if (request.getPrice() != null) product.setPrice(request.getPrice());
        if (request.getCost() != null) product.setCost(request.getCost());
        if (request.getTone() != null) product.setTone(request.getTone());
        if (request.getStatus() != null) product.setStatus(request.getStatus());
        if (request.getVariantId() != null) product.setVariant(
                variantRepository.findById(request.getVariantId())
                        .orElseThrow(() -> new AppException("Variant not found")));
        if (request.getCategoryId() != null) product.setCategory(resolveCategory(request.getCategoryId()));
        if (request.getLineId() != null) product.setLine(resolveLine(request.getLineId()));

        Product saved = productRepository.save(product);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Update Product")
                .description(String.format("Product '%s' (code: %s) has been updated", saved.getName(), saved.getCode()))
                .build());

        return toResponse(productRepository.findByUuidAndDeletedAtIsNull(saved.getUuid())
                .orElse(saved));
    }

    @Override
    @Transactional
    public void deleteOne(UUID uuid) {
        Product product = productRepository.findByUuid(uuid)
                .orElseThrow(() -> new AppException("Product not found"));
        if (product.getDeletedAt() != null) {
            throw new AppException("Product not found");
        }

        String deletedBy = SecurityContextHolder.getContext().getAuthentication().getName();
        product.setDeletedAt(Instant.now());
        product.setDeletedBy(deletedBy);
        productRepository.save(product);

        auditLogService.create(AuditLogCreateRequest.builder()
                .context("Delete Product")
                .description(String.format("Product '%s' (code: %s) has been deleted", product.getName(), product.getCode()))
                .build());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductSearchResponse> search(String q, int size) {
        int limit = Math.min(size, 50);
        return productRepository.searchByNameOrCode(q == null ? "" : q, limit)
                .stream()
                .map(p -> ProductSearchResponse.builder()
                        .uuid(p.getUuid())
                        .code(p.getCode())
                        .name(p.getName())
                        .variantSize(p.getVariant() != null ? p.getVariant().getSize() : null)
                        .variantColor(p.getVariant() != null ? p.getVariant().getColor() : null)
                        .currentStock(p.getStockLevel() != null ? p.getStockLevel().getQuantity() : null)
                        .build())
                .toList();
    }

    private ProductCategory resolveCategory(Long id) {
        if (id == null) return null;
        return categoryRepository.findById(id)
                .orElseThrow(() -> new AppException("Category not found"));
    }

    private ProductLine resolveLine(Long id) {
        if (id == null) return null;
        return lineRepository.findById(id)
                .orElseThrow(() -> new AppException("Product line not found"));
    }

    private Long currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User user) {
            return user.getId();
        }
        return null;
    }

    private ProductResponse toResponse(Product p) {
        ModelVariant v = p.getVariant();
        ProductModel model = v != null ? v.getModel() : null;
        return ProductResponse.builder()
                .id(p.getId())
                .uuid(p.getUuid())
                .code(p.getCode())
                .name(p.getName())
                .sku(p.getSku())
                .price(p.getPrice())
                .cost(p.getCost())
                .tone(p.getTone())
                .status(p.getStatus())
                .currentStock(p.getStockLevel() != null ? p.getStockLevel().getQuantity() : null)
                .variantId(v != null ? v.getId() : null)
                .variantSize(v != null ? v.getSize() : null)
                .variantColor(v != null ? v.getColor() : null)
                .modelId(model != null ? model.getId() : null)
                .modelName(model != null ? model.getName() : null)
                .categoryId(p.getCategory() != null ? p.getCategory().getId() : null)
                .categoryName(p.getCategory() != null ? p.getCategory().getName() : null)
                .lineId(p.getLine() != null ? p.getLine().getId() : null)
                .lineName(p.getLine() != null ? p.getLine().getName() : null)
                .createdAt(p.getCreatedAt())
                .createdBy(p.getCreatedBy())
                .updatedAt(p.getUpdatedAt())
                .updatedBy(p.getUpdatedBy())
                .build();
    }
}
