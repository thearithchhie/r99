package com.r99.r99_shop_api.module.delivery.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.commission.entity.CommissionStatus;
import com.r99.r99_shop_api.module.commission.entity.DeliveryCommission;
import com.r99.r99_shop_api.module.commission.repository.DeliveryCommissionRepository;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryCreateRequest;
import com.r99.r99_shop_api.module.delivery.dto.request.DeliveryStatusUpdateRequest;
import com.r99.r99_shop_api.module.delivery.dto.response.DeliveryResponse;
import com.r99.r99_shop_api.module.delivery.entity.Delivery;
import com.r99.r99_shop_api.module.delivery.entity.DeliveryStatus;
import com.r99.r99_shop_api.module.delivery.repository.DeliveryRepository;
import com.r99.r99_shop_api.module.driver.entity.Driver;
import com.r99.r99_shop_api.module.driver.repository.DriverRepository;
import com.r99.r99_shop_api.module.order.entity.Order;
import com.r99.r99_shop_api.module.order.entity.OrderStatus;
import com.r99.r99_shop_api.module.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeliveryServiceImpl implements DeliveryService {

    private final DeliveryRepository deliveryRepository;
    private final OrderRepository orderRepository;
    private final DriverRepository driverRepository;
    private final DeliveryCommissionRepository deliveryCommissionRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<DeliveryResponse> findAll(Pageable pageable) {
        return PagedResponse.of(
                deliveryRepository.findAllByDeletedAtIsNull(pageable).map(this::toResponse),
                "deliveries");
    }

    @Override
    @Transactional(readOnly = true)
    public DeliveryResponse findOne(UUID uuid) {
        return toResponse(deliveryRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Delivery not found")));
    }

    @Override
    @Transactional
    public DeliveryResponse create(DeliveryCreateRequest request) {
        Order order = orderRepository.findByUuidAndDeletedAtIsNull(request.getOrderUuid())
                .orElseThrow(() -> new AppException("Order not found"));

        if (deliveryRepository.findByOrderId(order.getId()).isPresent()) {
            throw new AppException("Delivery already exists for this order");
        }

        Driver driver = null;
        if (request.getDriverUuid() != null) {
            driver = driverRepository.findByUuidAndDeletedAtIsNull(request.getDriverUuid())
                    .orElseThrow(() -> new AppException("Driver not found"));
        }

        var customer = order.getCustomer();
        Delivery delivery = Delivery.builder()
                .order(order)
                .driver(driver)
                .partnerType(request.getPartnerType())
                .deliveryCost(request.getDeliveryCost())
                .recipientName(customer.getName())
                .recipientPhone(customer.getPhone())
                .recipientAddress(customer.getAddress() != null ? customer.getAddress() : "")
                .note(request.getNote())
                .build();

        return toResponse(deliveryRepository.save(delivery));
    }

    @Override
    @Transactional
    public DeliveryResponse updateStatus(UUID uuid, DeliveryStatusUpdateRequest request) {
        Delivery delivery = deliveryRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Delivery not found"));

        DeliveryStatus newStatus = request.getStatus();
        delivery.setStatus(newStatus);
        if (request.getNote() != null) delivery.setNote(request.getNote());

        if (newStatus == DeliveryStatus.DELIVERED) {
            delivery.setDeliveredAt(Instant.now());
            delivery.getOrder().setStatus(OrderStatus.DELIVERED);
            orderRepository.save(delivery.getOrder());
            createDriverCommission(delivery);
        }

        return toResponse(deliveryRepository.save(delivery));
    }

    private void createDriverCommission(Delivery delivery) {
        if (delivery.getDriver() == null) return;
        boolean alreadyExists = deliveryCommissionRepository.findByDeliveryId(delivery.getId()).isPresent();
        if (alreadyExists) return;

        deliveryCommissionRepository.save(DeliveryCommission.builder()
                .delivery(delivery)
                .driver(delivery.getDriver())
                .partnerType(delivery.getPartnerType())
                .amount(delivery.getDeliveryCost())
                .status(CommissionStatus.PENDING)
                .build());

        delivery.setCommissionEarned(delivery.getDeliveryCost());
    }

    private DeliveryResponse toResponse(Delivery d) {
        return DeliveryResponse.builder()
                .id(d.getId())
                .uuid(d.getUuid())
                .orderUuid(d.getOrder().getUuid())
                .recipientName(d.getRecipientName())
                .recipientPhone(d.getRecipientPhone())
                .recipientAddress(d.getRecipientAddress())
                .driverId(d.getDriver() != null ? d.getDriver().getId() : null)
                .driverName(d.getDriver() != null ? d.getDriver().getName() : null)
                .driverPhone(d.getDriver() != null ? d.getDriver().getPhone() : null)
                .partnerType(d.getPartnerType())
                .status(d.getStatus())
                .deliveryCost(d.getDeliveryCost())
                .commissionEarned(d.getCommissionEarned())
                .commissionReceivedAt(d.getCommissionReceivedAt())
                .deliveredAt(d.getDeliveredAt())
                .note(d.getNote())
                .createdAt(d.getCreatedAt())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}
