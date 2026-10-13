package com.r99.r99_shop_api.module.purchase.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.product.entity.Product;
import com.r99.r99_shop_api.module.product.repository.ProductRepository;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseCreateItemRequest;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseCreateRequest;
import com.r99.r99_shop_api.module.purchase.dto.request.PurchaseReceiveRequest;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseArrivalResponse;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseItemResponse;
import com.r99.r99_shop_api.module.purchase.dto.response.PurchaseResponse;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseOrder;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseOrderItem;
import com.r99.r99_shop_api.module.purchase.entity.PurchaseStatus;
import com.r99.r99_shop_api.module.purchase.repository.PurchaseOrderItemRepository;
import com.r99.r99_shop_api.module.purchase.repository.PurchaseOrderRepository;
import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import com.r99.r99_shop_api.module.stock.repository.StockLevelRepository;
import com.r99.r99_shop_api.module.stock.repository.StockMovementRepository;
import com.r99.r99_shop_api.module.supplier.entity.Supplier;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import com.r99.r99_shop_api.module.supplier.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PurchaseServiceImpl implements PurchaseService {

    private final PurchaseOrderRepository purchaseOrderRepository;
    private final PurchaseOrderItemRepository purchaseOrderItemRepository;
    private final SupplierRepository supplierRepository;
    private final ProductRepository productRepository;
    private final StockLevelRepository stockLevelRepository;
    private final StockMovementRepository stockMovementRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<PurchaseResponse> findAll(PurchaseStatus status, Pageable pageable) {
        var page = status == null
                ? purchaseOrderRepository.findAllByDeletedAtIsNull(pageable)
                : purchaseOrderRepository.findAllByStatusAndDeletedAtIsNull(status, pageable);
        return PagedResponse.of(page.map(this::toResponse), "purchases");
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<PurchaseResponse> findAllBySupplier(UUID supplierUuid, Pageable pageable) {
        return PagedResponse.of(
                purchaseOrderRepository.findAllBySupplier_UuidAndDeletedAtIsNull(supplierUuid, pageable)
                        .map(this::toResponse),
                "purchases");
    }

    @Override
    @Transactional(readOnly = true)
    public PurchaseResponse findOne(UUID uuid) {
        return toResponse(findByUuid(uuid));
    }

    @Override
    @Transactional
    public PurchaseResponse create(PurchaseCreateRequest request) {
        Supplier supplier = supplierRepository.findByUuidAndDeletedAtIsNull(request.getSupplierUuid())
                .orElseThrow(() -> new AppException("Supplier not found"));
        if (supplier.getStatus() != SupplierStatus.ACTIVE) {
            throw new AppException("Supplier is not active");
        }

        PurchaseOrder order = PurchaseOrder.builder()
                .supplier(supplier)
                .orderNumber(generateOrderNumber())
                .note(request.getNote())
                .discountAmount(nullSafe(request.getDiscountAmount()))
                .taxAmount(nullSafe(request.getTaxAmount()))
                .shippingCost(nullSafe(request.getShippingCost()))
                .build();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (PurchaseCreateItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findByUuidAndDeletedAtIsNull(itemReq.getProductUuid())
                    .orElseThrow(() -> new AppException("Product not found: " + itemReq.getProductUuid()));

            BigDecimal itemDiscount = nullSafe(itemReq.getDiscountAmount());
            BigDecimal itemSubtotal = itemReq.getCostPrice()
                    .multiply(BigDecimal.valueOf(itemReq.getQuantity()))
                    .subtract(itemDiscount);

            PurchaseOrderItem item = PurchaseOrderItem.builder()
                    .purchaseOrder(order)
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .costPrice(itemReq.getCostPrice())
                    .discountAmount(itemDiscount)
                    .subtotal(itemSubtotal)
                    .build();

            order.getItems().add(item);
            subtotal = subtotal.add(itemSubtotal);
        }

        order.setSubtotal(subtotal);
        order.setTotalAmount(subtotal
                .subtract(order.getDiscountAmount())
                .add(order.getTaxAmount())
                .add(order.getShippingCost()));

        return toResponse(purchaseOrderRepository.save(order));
    }

    @Override
    @Transactional
    public PurchaseResponse update(UUID uuid, PurchaseCreateRequest request) {
        PurchaseOrder order = findByUuid(uuid);
        if (order.getStatus() != PurchaseStatus.DRAFT) {
            throw new AppException("Only DRAFT purchases can be edited");
        }

        Supplier supplier = supplierRepository.findByUuidAndDeletedAtIsNull(request.getSupplierUuid())
                .orElseThrow(() -> new AppException("Supplier not found"));
        if (supplier.getStatus() != SupplierStatus.ACTIVE) {
            throw new AppException("Supplier is not active");
        }

        order.setSupplier(supplier);
        order.setNote(request.getNote());
        order.setDiscountAmount(nullSafe(request.getDiscountAmount()));
        order.setTaxAmount(nullSafe(request.getTaxAmount()));
        order.setShippingCost(nullSafe(request.getShippingCost()));
        order.getItems().clear();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (PurchaseCreateItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findByUuidAndDeletedAtIsNull(itemReq.getProductUuid())
                    .orElseThrow(() -> new AppException("Product not found: " + itemReq.getProductUuid()));

            BigDecimal itemDiscount = nullSafe(itemReq.getDiscountAmount());
            BigDecimal itemSubtotal = itemReq.getCostPrice()
                    .multiply(BigDecimal.valueOf(itemReq.getQuantity()))
                    .subtract(itemDiscount);

            order.getItems().add(PurchaseOrderItem.builder()
                    .purchaseOrder(order)
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .costPrice(itemReq.getCostPrice())
                    .discountAmount(itemDiscount)
                    .subtotal(itemSubtotal)
                    .build());

            subtotal = subtotal.add(itemSubtotal);
        }

        order.setSubtotal(subtotal);
        order.setTotalAmount(subtotal
                .subtract(order.getDiscountAmount())
                .add(order.getTaxAmount())
                .add(order.getShippingCost()));

        return toResponse(purchaseOrderRepository.save(order));
    }

    @Override
    @Transactional
    public PurchaseResponse confirm(UUID uuid) {
        PurchaseOrder order = findByUuid(uuid);
        if (order.getStatus() != PurchaseStatus.DRAFT) {
            throw new AppException("Only DRAFT purchases can be confirmed");
        }
        order.setStatus(PurchaseStatus.ORDERED);
        order.setOrderedAt(Instant.now());
        return toResponse(purchaseOrderRepository.save(order));
    }

    @Override
    @Transactional
    public PurchaseResponse receive(UUID uuid, PurchaseReceiveRequest request) {
        PurchaseOrder order = purchaseOrderRepository.findByUuidForUpdate(uuid)
                .orElseThrow(() -> new AppException("Purchase not found"));

        if (order.getStatus() != PurchaseStatus.ORDERED && order.getStatus() != PurchaseStatus.PARTIALLY_RECEIVED) {
            throw new AppException("Purchase must be in ORDERED or PARTIALLY_RECEIVED status to receive items");
        }

        for (var itemReq : request.getItems()) {
            PurchaseOrderItem item = purchaseOrderItemRepository.findByUuid(itemReq.getPurchaseItemUuid())
                    .orElseThrow(() -> new AppException("Purchase item not found: " + itemReq.getPurchaseItemUuid()));

            if (!item.getPurchaseOrder().getId().equals(order.getId())) {
                throw new AppException("Purchase item does not belong to this purchase order");
            }

            int remaining = item.getQuantity() - item.getReceivedQuantity();
            if (itemReq.getReceivedQuantity() > remaining) {
                throw new AppException("Cannot receive " + itemReq.getReceivedQuantity()
                        + " units for item — only " + remaining + " remaining");
            }

            item.setReceivedQuantity(item.getReceivedQuantity() + itemReq.getReceivedQuantity());
            purchaseOrderItemRepository.save(item);

            increaseStock(item.getProduct(), itemReq.getReceivedQuantity(), order.getUuid());
        }

        boolean allReceived = order.getItems().stream()
                .allMatch(i -> i.getReceivedQuantity().equals(i.getQuantity()));
        order.setStatus(allReceived ? PurchaseStatus.RECEIVED : PurchaseStatus.PARTIALLY_RECEIVED);

        return toResponse(purchaseOrderRepository.save(order));
    }

    @Override
    @Transactional
    public PurchaseResponse cancel(UUID uuid) {
        PurchaseOrder order = findByUuid(uuid);
        if (order.getStatus() == PurchaseStatus.RECEIVED) {
            throw new AppException("Cannot cancel a fully received purchase. Use a return/reversal process instead.");
        }
        if (order.getStatus() == PurchaseStatus.CANCELLED) {
            throw new AppException("Purchase is already cancelled");
        }
        order.setStatus(PurchaseStatus.CANCELLED);
        return toResponse(purchaseOrderRepository.save(order));
    }

    @Override
    @Transactional(readOnly = true)
    public List<PurchaseArrivalResponse> arrivals(UUID uuid) {
        PurchaseOrder order = findByUuid(uuid);
        return stockMovementRepository
                .findAllByReasonAndReferenceIdOrderByCreatedAtAsc("PURCHASE", order.getUuid().toString())
                .stream()
                .map(m -> PurchaseArrivalResponse.builder()
                        .productUuid(m.getProduct().getUuid())
                        .productName(m.getProduct().getName())
                        .productCode(m.getProduct().getCode())
                        .quantityReceived(m.getDelta())
                        .arrivedAt(m.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    private void increaseStock(Product product, int qty, UUID purchaseUuid) {
        if (qty <= 0) return;

        StockLevel level = stockLevelRepository.findByProductId(product.getId())
                .orElseGet(() -> StockLevel.builder().product(product).quantity(0).build());
        level.setQuantity(level.getQuantity() + qty);
        stockLevelRepository.save(level);

        stockMovementRepository.save(StockMovement.builder()
                .product(product)
                .delta(qty)
                .reason("PURCHASE")
                .referenceId(purchaseUuid.toString())
                .build());
    }

    private String generateOrderNumber() {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        long seq = purchaseOrderRepository.countTodayOrders() + 1;
        return String.format("PO-%s-%04d", date, seq);
    }

    private BigDecimal nullSafe(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private PurchaseOrder findByUuid(UUID uuid) {
        return purchaseOrderRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Purchase not found"));
    }

    private PurchaseResponse toResponse(PurchaseOrder order) {
        List<PurchaseItemResponse> items = order.getItems() == null ? List.of() :
                order.getItems().stream().map(this::toItemResponse).toList();

        return PurchaseResponse.builder()
                .id(order.getId())
                .uuid(order.getUuid())
                .orderNumber(order.getOrderNumber())
                .status(order.getStatus())
                .supplierUuid(order.getSupplier().getUuid())
                .supplierName(order.getSupplier().getName())
                .subtotal(order.getSubtotal())
                .discountAmount(order.getDiscountAmount())
                .taxAmount(order.getTaxAmount())
                .shippingCost(order.getShippingCost())
                .totalAmount(order.getTotalAmount())
                .items(items)
                .note(order.getNote())
                .orderedAt(order.getOrderedAt())
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .build();
    }

    private PurchaseItemResponse toItemResponse(PurchaseOrderItem item) {
        return PurchaseItemResponse.builder()
                .uuid(item.getUuid())
                .productUuid(item.getProduct().getUuid())
                .productName(item.getProduct().getName())
                .productCode(item.getProduct().getCode())
                .quantity(item.getQuantity())
                .receivedQuantity(item.getReceivedQuantity())
                .remainingQuantity(item.getQuantity() - item.getReceivedQuantity())
                .costPrice(item.getCostPrice())
                .discountAmount(item.getDiscountAmount())
                .subtotal(item.getSubtotal())
                .build();
    }
}
