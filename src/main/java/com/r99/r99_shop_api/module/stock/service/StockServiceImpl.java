package com.r99.r99_shop_api.module.stock.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.auth.entity.User;
import com.r99.r99_shop_api.module.product.entity.Product;
import com.r99.r99_shop_api.module.product.repository.ProductRepository;
import com.r99.r99_shop_api.module.stock.dto.request.StockMovementRequest;
import com.r99.r99_shop_api.module.stock.dto.response.StockLevelResponse;
import com.r99.r99_shop_api.module.stock.dto.response.StockMovementResponse;
import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import com.r99.r99_shop_api.module.stock.repository.StockLevelRepository;
import com.r99.r99_shop_api.module.stock.repository.StockMovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StockServiceImpl implements StockService {

    private final StockLevelRepository stockLevelRepository;
    private final StockMovementRepository stockMovementRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<StockLevelResponse> findAll(Pageable pageable) {
        Page<StockLevelResponse> page = stockLevelRepository.findAll(pageable)
                .map(this::toLevelResponse);
        return PagedResponse.of(page, "stock_levels");
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<StockMovementResponse> findMovements(Pageable pageable) {
        Page<StockMovementResponse> page = stockMovementRepository.findAll(pageable)
                .map(this::toMovementResponse);
        return PagedResponse.of(page, "stock_movements");
    }

    @Override
    @Transactional
    public StockMovementResponse addMovement(StockMovementRequest request) {
        Product product = productRepository.findByUuid(request.getProductUuid())
                .orElseThrow(() -> new AppException("Product not found"));
        if (product.getDeletedAt() != null) {
            throw new AppException("Product not found");
        }

        StockLevel stockLevel = stockLevelRepository.findByProductId(product.getId())
                .orElseThrow(() -> new AppException("Stock level not found for this product"));

        int newQuantity = stockLevel.getQuantity() + request.getDelta();
        if (newQuantity < 0) {
            throw new AppException("Insufficient stock. Current quantity: " + stockLevel.getQuantity());
        }

        stockLevel.setQuantity(newQuantity);
        stockLevelRepository.save(stockLevel);

        StockMovement movement = StockMovement.builder()
                .product(product)
                .delta(request.getDelta())
                .reason(request.getReason())
                .referenceId(request.getReferenceId())
                .note(request.getNote())
                .createdBy(currentUserId())
                .build();

        StockMovement saved = stockMovementRepository.save(movement);
        return toMovementResponse(saved);
    }

    private Long currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User user) {
            return user.getId();
        }
        return null;
    }

    private StockLevelResponse toLevelResponse(StockLevel s) {
        Product p = s.getProduct();
        return StockLevelResponse.builder()
                .id(s.getId())
                .productId(p != null ? p.getId() : null)
                .productCode(p != null ? p.getCode() : null)
                .productName(p != null ? p.getName() : null)
                .quantity(s.getQuantity())
                .updatedAt(s.getUpdatedAt())
                .build();
    }

    private StockMovementResponse toMovementResponse(StockMovement m) {
        Product p = m.getProduct();
        return StockMovementResponse.builder()
                .id(m.getId())
                .productId(p != null ? p.getId() : null)
                .productCode(p != null ? p.getCode() : null)
                .productName(p != null ? p.getName() : null)
                .delta(m.getDelta())
                .reason(m.getReason())
                .referenceId(m.getReferenceId())
                .note(m.getNote())
                .createdBy(m.getCreatedBy())
                .createdAt(m.getCreatedAt())
                .build();
    }
}
