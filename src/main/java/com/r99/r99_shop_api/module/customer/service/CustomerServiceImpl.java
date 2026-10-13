package com.r99.r99_shop_api.module.customer.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerCreateRequest;
import com.r99.r99_shop_api.module.customer.dto.request.CustomerUpdateRequest;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerDetailResponse;
import com.r99.r99_shop_api.module.customer.dto.response.CustomerResponse;
import com.r99.r99_shop_api.module.customer.entity.Customer;
import com.r99.r99_shop_api.module.customer.repository.CustomerRepository;
import com.r99.r99_shop_api.module.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;
    private final OrderRepository orderRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<CustomerResponse> findAll(Pageable pageable) {
        return PagedResponse.of(
                customerRepository.findAllByDeletedAtIsNull(pageable).map(this::toResponse),
                "customers");
    }

    @Override
    @Transactional(readOnly = true)
    public CustomerDetailResponse findOne(UUID uuid) {
        Customer c = customerRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Customer not found"));

        Object[] stats = orderRepository.fetchCustomerStats(c.getUuid()).get(0);

        long   totalOrders     = ((Number) stats[0]).longValue();
        long   completedOrders = ((Number) stats[1]).longValue();
        BigDecimal totalPaid   = new BigDecimal(stats[2].toString());
        long   pendingOrders   = ((Number) stats[3]).longValue();
        long   cancelledOrders = ((Number) stats[4]).longValue();
        BigDecimal refunded    = new BigDecimal(stats[5].toString());
        BigDecimal netSpent    = totalPaid.subtract(refunded);

        return CustomerDetailResponse.builder()
                .id(c.getId())
                .uuid(c.getUuid())
                .name(c.getName())
                .phone(c.getPhone())
                .address(c.getAddress())
                .province(c.getProvince())
                .facebookName(c.getFacebookName())
                .totalOrders(totalOrders)
                .completedOrders(completedOrders)
                .totalPaid(totalPaid)
                .netSpent(netSpent)
                .pendingOrders(pendingOrders)
                .cancelledOrders(cancelledOrders)
                .refunded(refunded)
                .note(c.getNote())
                .createdAt(c.getCreatedAt())
                .updatedAt(c.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CustomerResponse> search(String q, int size) {
        return customerRepository.searchByNameOrPhone(q == null ? "" : q, Math.min(size, 50))
                .stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public CustomerResponse create(CustomerCreateRequest request) {
        Customer saved = customerRepository.save(Customer.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .address(request.getAddress())
                .province(request.getProvince())
                .facebookName(request.getFacebookName())
                .note(request.getNote())
                .build());
        return toResponse(saved);
    }

    @Override
    @Transactional
    public CustomerResponse update(UUID uuid, CustomerUpdateRequest request) {
        Customer customer = customerRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Customer not found"));
        if (request.getName() != null)        customer.setName(request.getName());
        if (request.getPhone() != null)       customer.setPhone(request.getPhone());
        if (request.getAddress() != null)     customer.setAddress(request.getAddress());
        if (request.getProvince() != null)    customer.setProvince(request.getProvince());
        if (request.getFacebookName() != null) customer.setFacebookName(request.getFacebookName());
        if (request.getNote() != null)        customer.setNote(request.getNote());
        return toResponse(customerRepository.save(customer));
    }

    @Override
    @Transactional
    public void delete(UUID uuid) {
        Customer customer = customerRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Customer not found"));
        customer.setDeletedAt(Instant.now());
        customerRepository.save(customer);
    }

    private CustomerResponse toResponse(Customer c) {
        return CustomerResponse.builder()
                .id(c.getId())
                .uuid(c.getUuid())
                .name(c.getName())
                .phone(c.getPhone())
                .address(c.getAddress())
                .province(c.getProvince())
                .facebookName(c.getFacebookName())
                .note(c.getNote())
                .createdAt(c.getCreatedAt())
                .updatedAt(c.getUpdatedAt())
                .build();
    }
}
