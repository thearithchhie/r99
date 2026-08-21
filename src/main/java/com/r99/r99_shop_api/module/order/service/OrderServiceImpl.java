package com.r99.r99_shop_api.module.order.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.auth.entity.User;
import com.r99.r99_shop_api.module.commission.entity.CommissionStatus;
import com.r99.r99_shop_api.module.commission.entity.StaffCommission;
import com.r99.r99_shop_api.module.commission.repository.StaffCommissionRepository;
import com.r99.r99_shop_api.module.customer.entity.Customer;
import com.r99.r99_shop_api.module.customer.repository.CustomerRepository;
import com.r99.r99_shop_api.module.order.dto.request.OrderCreateRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderItemRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderPartialReturnItemRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderPartialReturnRequest;
import com.r99.r99_shop_api.module.order.dto.request.OrderStatusUpdateRequest;
import com.r99.r99_shop_api.module.order.dto.response.OrderItemResponse;
import com.r99.r99_shop_api.module.order.dto.response.OrderResponse;
import com.r99.r99_shop_api.module.order.entity.Order;
import com.r99.r99_shop_api.module.order.entity.OrderItem;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import com.r99.r99_shop_api.module.order.entity.ReturnReason;
import com.r99.r99_shop_api.module.order.repository.OrderRepository;
import com.r99.r99_shop_api.module.product.entity.Product;
import com.r99.r99_shop_api.module.product.repository.ProductRepository;
import com.r99.r99_shop_api.module.stock.entity.StockLevel;
import com.r99.r99_shop_api.module.stock.entity.StockMovement;
import com.r99.r99_shop_api.module.stock.repository.StockLevelRepository;
import com.r99.r99_shop_api.module.stock.repository.StockMovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private static final BigDecimal STAFF_COMMISSION_WEEKDAY = new BigDecimal("0.50");
    private static final BigDecimal STAFF_COMMISSION_WEEKEND = new BigDecimal("0.75");
    private static final BigDecimal DELIVERY_FEE_NORMAL      = new BigDecimal("2.00");

    private final OrderRepository                                             orderRepository;
    private final CustomerRepository                                          customerRepository;
    private final ProductRepository                                           productRepository;
    private final StockLevelRepository                                        stockLevelRepository;
    private final StockMovementRepository                                     stockMovementRepository;
    private final StaffCommissionRepository                                   staffCommissionRepository;
    private final com.r99.r99_shop_api.module.auth.repository.UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<OrderResponse> findAll(OrderStatus status, Pageable pageable) {
        var page = status != null
                ? orderRepository.findAllByStatusAndDeletedAtIsNull(status, pageable)
                : orderRepository.findAllByDeletedAtIsNull(pageable);
        return PagedResponse.of(page.map(this::toResponse), "orders");
    }

    @Override
    @Transactional(readOnly = true)
    public OrderResponse findOne(UUID uuid) {
        return toResponse(orderRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Order not found")));
    }

    @Override
    @Transactional
    public OrderResponse create(OrderCreateRequest request) {
        Customer customer = customerRepository.findByUuidAndDeletedAtIsNull(request.getCustomerUuid())
                .orElseThrow(() -> new AppException("Customer not found"));

        User staff = request.getStaffUuid() != null
                ? userRepository.findByUuid(request.getStaffUuid())
                        .orElseThrow(() -> new AppException("Staff not found"))
                : currentUser();

        boolean isPromotion = Boolean.TRUE.equals(request.getIsPromotion());
        BigDecimal deliveryFee = isPromotion ? BigDecimal.ZERO : DELIVERY_FEE_NORMAL;

        Order order = Order.builder()
                .customer(customer)
                .staff(staff)
                .pageSource(request.getPageSource())
                .paymentType(request.getPaymentType())
                .paymentMethod(request.getPaymentMethod())
                .isPromotion(isPromotion)
                .deliveryFee(deliveryFee)
                .note(request.getNote())
                .subtotal(BigDecimal.ZERO)
                .totalAmount(BigDecimal.ZERO)
                .build();

        BigDecimal subtotal = BigDecimal.ZERO;

        for (OrderItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findByUuidAndDeletedAtIsNull(itemReq.getProductUuid())
                    .orElseThrow(() -> new AppException("Product not found: " + itemReq.getProductUuid()));

            deductStock(product, itemReq.getQuantity());

            BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(itemReq.getQuantity()));
            subtotal = subtotal.add(lineTotal);

            OrderItem item = OrderItem.builder()
                    .order(order)
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .unitPrice(product.getPrice())
                    .unitCost(product.getCost())
                    .build();
            order.getItems().add(item);
        }

        order.setSubtotal(subtotal);
        order.setTotalAmount(subtotal.add(deliveryFee));

        Order saved = orderRepository.save(order);

        createStaffCommission(saved, staff);

        return toResponse(orderRepository.findByUuidAndDeletedAtIsNull(saved.getUuid()).orElse(saved));
    }

    @Override
    @Transactional
    public OrderResponse updateStatus(UUID uuid, OrderStatusUpdateRequest request) {
        Order order = orderRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Order not found"));

        OrderStatus newStatus = request.getStatus();
        order.setStatus(newStatus);
        if (request.getReturnReason() != null) order.setReturnReason(request.getReturnReason());
        if (request.getNote() != null)         order.setNote(request.getNote());

        handleCommissionOnStatusChange(order, newStatus, request.getReturnReason());

        if (newStatus == OrderStatus.CANCELLED || newStatus == OrderStatus.RETURNED) {
            restoreStock(order);
        }

        return toResponse(orderRepository.save(order));
    }

    @Override
    @Transactional
    public OrderResponse partialReturn(UUID uuid, OrderPartialReturnRequest request) {
        Order order = orderRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Order not found"));

        Map<UUID, OrderItem> itemsByProductUuid = order.getItems().stream()
                .collect(java.util.stream.Collectors.toMap(
                        i -> i.getProduct().getUuid(),
                        i -> i));

        for (OrderPartialReturnItemRequest returnItem : request.getItems()) {
            OrderItem orderItem = itemsByProductUuid.get(returnItem.getProductUuid());
            if (orderItem == null) {
                throw new AppException("Product not found in this order: " + returnItem.getProductUuid());
            }
            if (returnItem.getQuantity() > orderItem.getQuantity()) {
                throw new AppException("Return quantity exceeds ordered quantity for product: "
                        + orderItem.getProduct().getCode());
            }
            restoreStockForItem(orderItem.getProduct(), returnItem.getQuantity());
        }

        order.setStatus(OrderStatus.PARTIALLY_RETURNED);
        order.setReturnReason(request.getReturnReason());
        if (request.getNote() != null) order.setNote(request.getNote());

        handleCommissionOnStatusChange(order, OrderStatus.PARTIALLY_RETURNED, request.getReturnReason());

        return toResponse(orderRepository.save(order));
    }

    // ── Stock helpers ──────────────────────────────────────────────────────────

    private void deductStock(Product product, int qty) {
        StockLevel level = stockLevelRepository.findByProductId(product.getId())
                .orElseThrow(() -> new AppException("Stock level not found for product: " + product.getCode()));
        int newQty = level.getQuantity() - qty;
        if (newQty < 0) {
            throw new AppException("Insufficient stock for product: " + product.getCode()
                    + ". Available: " + level.getQuantity());
        }
        level.setQuantity(newQty);
        stockLevelRepository.save(level);

        stockMovementRepository.save(StockMovement.builder()
                .product(product)
                .delta(-qty)
                .reason("sale")
                .createdBy(currentUserId())
                .build());
    }

    private void restoreStock(Order order) {
        for (OrderItem item : order.getItems()) {
            restoreStockForItem(item.getProduct(), item.getQuantity());
        }
    }

    private void restoreStockForItem(Product product, int qty) {
        StockLevel level = stockLevelRepository.findByProductId(product.getId())
                .orElseThrow(() -> new AppException("Stock level not found"));
        level.setQuantity(level.getQuantity() + qty);
        stockLevelRepository.save(level);

        stockMovementRepository.save(StockMovement.builder()
                .product(product)
                .delta(qty)
                .reason("returned")
                .createdBy(currentUserId())
                .build());
    }

    // ── Commission helpers ─────────────────────────────────────────────────────

    private void createStaffCommission(Order order, User staff) {
        if (staff == null) return;
        boolean isWeekend = isWeekend();
        BigDecimal amount = isWeekend ? STAFF_COMMISSION_WEEKEND : STAFF_COMMISSION_WEEKDAY;
        staffCommissionRepository.save(StaffCommission.builder()
                .order(order)
                .staff(staff)
                .amount(amount)
                .isWeekend(isWeekend)
                .status(CommissionStatus.PENDING)
                .build());
    }

    private void handleCommissionOnStatusChange(Order order, OrderStatus newStatus, ReturnReason reason) {
        staffCommissionRepository.findByOrderId(order.getId()).ifPresent(commission -> {
            switch (newStatus) {
                case CANCELLED -> commission.setStatus(CommissionStatus.CANCELLED);
                case RETURNED -> {
                    if (reason != ReturnReason.STORE_ERROR) {
                        commission.setStatus(commission.getStatus() == CommissionStatus.PAID
                                ? CommissionStatus.DEDUCTED
                                : CommissionStatus.CANCELLED);
                    }
                }
                // partial return — staff keeps commission regardless of reason
                default -> { }
            }
            staffCommissionRepository.save(commission);
        });
    }

    // ── Auth helpers ───────────────────────────────────────────────────────────

    private User currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User user) return user;
        return null;
    }

    private Long currentUserId() {
        User user = currentUser();
        return user != null ? user.getId() : null;
    }

    private boolean isWeekend() {
        DayOfWeek day = ZonedDateTime.now(ZoneId.of("Asia/Phnom_Penh")).getDayOfWeek();
        return day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
    }

    // ── Mapping ────────────────────────────────────────────────────────────────

    private OrderResponse toResponse(Order o) {
        List<OrderItemResponse> items = o.getItems().stream().map(i -> OrderItemResponse.builder()
                .productId(i.getProduct().getId())
                .productCode(i.getProduct().getCode())
                .productName(i.getProduct().getName())
                .quantity(i.getQuantity())
                .unitPrice(i.getUnitPrice())
                .unitCost(i.getUnitCost())
                .subtotal(i.getUnitPrice().multiply(BigDecimal.valueOf(i.getQuantity())))
                .build()).toList();

        return OrderResponse.builder()
                .id(o.getId())
                .uuid(o.getUuid())
                .status(o.getStatus())
                .returnReason(o.getReturnReason())
                .customerId(o.getCustomer().getId())
                .customerName(o.getCustomer().getName())
                .customerPhone(o.getCustomer().getPhone())
                .staffId(o.getStaff() != null ? o.getStaff().getId() : null)
                .staffName(o.getStaff() != null ? o.getStaff().getUsername() : null)
                .pageSource(o.getPageSource())
                .paymentType(o.getPaymentType())
                .paymentMethod(o.getPaymentMethod())
                .isPromotion(o.getIsPromotion())
                .subtotal(o.getSubtotal())
                .deliveryFee(o.getDeliveryFee())
                .totalAmount(o.getTotalAmount())
                .items(items)
                .note(o.getNote())
                .createdAt(o.getCreatedAt())
                .updatedAt(o.getUpdatedAt())
                .build();
    }
}
