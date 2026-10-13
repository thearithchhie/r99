package com.r99.r99_shop_api.module.supplier.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierCreateRequest;
import com.r99.r99_shop_api.module.supplier.dto.request.SupplierUpdateRequest;
import com.r99.r99_shop_api.module.supplier.dto.response.SupplierResponse;
import com.r99.r99_shop_api.module.supplier.entity.Supplier;
import com.r99.r99_shop_api.module.supplier.entity.SupplierStatus;
import com.r99.r99_shop_api.module.supplier.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepository supplierRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<SupplierResponse> findAll(String search, SupplierStatus status, Pageable pageable) {
        return PagedResponse.of(
                supplierRepository.search(search, status, pageable).map(this::toResponse),
                "suppliers");
    }

    @Override
    @Transactional(readOnly = true)
    public SupplierResponse findOne(UUID uuid) {
        return toResponse(findByUuid(uuid));
    }

    @Override
    @Transactional
    public SupplierResponse create(SupplierCreateRequest request) {
        if (supplierRepository.existsByNameAndDeletedAtIsNull(request.getName())) {
            throw new AppException("Supplier name already exists");
        }
        Supplier saved = supplierRepository.save(Supplier.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .address(request.getAddress())
                .contactPerson(request.getContactPerson())
                .build());
        return toResponse(saved);
    }

    @Override
    @Transactional
    public SupplierResponse update(UUID uuid, SupplierUpdateRequest request) {
        Supplier supplier = findByUuid(uuid);
        if (request.getName() != null) {
            if (!request.getName().equals(supplier.getName())
                    && supplierRepository.existsByNameAndDeletedAtIsNull(request.getName())) {
                throw new AppException("Supplier name already exists");
            }
            supplier.setName(request.getName());
        }
        if (request.getPhone() != null)         supplier.setPhone(request.getPhone());
        if (request.getEmail() != null)         supplier.setEmail(request.getEmail());
        if (request.getAddress() != null)       supplier.setAddress(request.getAddress());
        if (request.getContactPerson() != null) supplier.setContactPerson(request.getContactPerson());
        if (request.getStatus() != null)        supplier.setStatus(request.getStatus());
        return toResponse(supplierRepository.save(supplier));
    }

    @Override
    @Transactional
    public void delete(UUID uuid) {
        Supplier supplier = findByUuid(uuid);
        supplier.setDeletedAt(Instant.now());
        supplierRepository.save(supplier);
    }

    private Supplier findByUuid(UUID uuid) {
        return supplierRepository.findByUuidAndDeletedAtIsNull(uuid)
                .orElseThrow(() -> new AppException("Supplier not found"));
    }

    private SupplierResponse toResponse(Supplier s) {
        return SupplierResponse.builder()
                .id(s.getId())
                .uuid(s.getUuid())
                .name(s.getName())
                .phone(s.getPhone())
                .email(s.getEmail())
                .address(s.getAddress())
                .contactPerson(s.getContactPerson())
                .status(s.getStatus())
                .createdAt(s.getCreatedAt())
                .updatedAt(s.getUpdatedAt())
                .build();
    }
}
