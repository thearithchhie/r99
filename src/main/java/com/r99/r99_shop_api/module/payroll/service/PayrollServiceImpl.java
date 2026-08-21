package com.r99.r99_shop_api.module.payroll.service;

import com.r99.r99_shop_api.common.exception.AppException;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.commission.entity.CommissionStatus;
import com.r99.r99_shop_api.module.commission.entity.DeliveryCommission;
import com.r99.r99_shop_api.module.commission.entity.StaffCommission;
import com.r99.r99_shop_api.module.commission.repository.DeliveryCommissionRepository;
import com.r99.r99_shop_api.module.commission.repository.StaffCommissionRepository;
import com.r99.r99_shop_api.module.payroll.dto.request.PayrollCreateRequest;
import com.r99.r99_shop_api.module.payroll.dto.response.PayrollItemResponse;
import com.r99.r99_shop_api.module.payroll.dto.response.PayrollResponse;
import com.r99.r99_shop_api.module.payroll.entity.Payroll;
import com.r99.r99_shop_api.module.payroll.entity.PayrollItem;
import com.r99.r99_shop_api.module.payroll.entity.PayrollStatus;
import com.r99.r99_shop_api.module.payroll.entity.RecipientType;
import com.r99.r99_shop_api.module.payroll.repository.PayrollRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PayrollServiceImpl implements PayrollService {

    private static final ZoneId TZ = ZoneId.of("Asia/Phnom_Penh");

    private final PayrollRepository             payrollRepository;
    private final StaffCommissionRepository     staffCommissionRepository;
    private final DeliveryCommissionRepository  deliveryCommissionRepository;

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<PayrollResponse> findAll(Pageable pageable) {
        return PagedResponse.of(
                payrollRepository.findAllByOrderByCreatedAtDesc(pageable).map(this::toResponse),
                "payrolls");
    }

    @Override
    @Transactional(readOnly = true)
    public PayrollResponse findOne(UUID uuid) {
        return toResponse(payrollRepository.findByUuidWithItems(uuid)
                .orElseThrow(() -> new AppException("Payroll not found")));
    }

    @Override
    @Transactional
    public PayrollResponse generate(PayrollCreateRequest request) {
        LocalDate weekStart = request.getWeekStart();
        LocalDate weekEnd   = request.getWeekEnd();

        Instant from = weekStart.atStartOfDay(TZ).toInstant();
        Instant to   = weekEnd.plusDays(1).atStartOfDay(TZ).toInstant();

        List<UUID> staffUuids  = request.getStaffUuids();
        List<UUID> driverUuids = request.getDriverUuids();

        List<StaffCommission> staffCommissions = (staffUuids != null && !staffUuids.isEmpty())
                ? staffCommissionRepository.findByStatusAndCreatedAtBetweenAndStaffUuidIn(CommissionStatus.PENDING, from, to, staffUuids)
                : staffCommissionRepository.findByStatusAndCreatedAtBetween(CommissionStatus.PENDING, from, to);

        List<DeliveryCommission> deliveryCommissions = (driverUuids != null && !driverUuids.isEmpty())
                ? deliveryCommissionRepository.findByStatusAndCreatedAtBetweenAndDriverUuidIn(CommissionStatus.PENDING, from, to, driverUuids)
                : deliveryCommissionRepository.findByStatusAndCreatedAtBetween(CommissionStatus.PENDING, from, to);

        if (staffCommissions.isEmpty() && deliveryCommissions.isEmpty()) {
            throw new AppException("No pending commissions found for the selected staff or drivers in this period");
        }

        Payroll payroll = Payroll.builder()
                .weekStart(weekStart)
                .weekEnd(weekEnd)
                .note(request.getNote())
                .build();

        List<PayrollItem> items = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        // Group staff commissions by staff
        Map<Long, List<StaffCommission>> byStaff = new LinkedHashMap<>();
        for (StaffCommission sc : staffCommissions) {
            byStaff.computeIfAbsent(sc.getStaff().getId(), k -> new ArrayList<>()).add(sc);
        }
        for (Map.Entry<Long, List<StaffCommission>> entry : byStaff.entrySet()) {
            List<StaffCommission> group = entry.getValue();
            BigDecimal lineTotal = group.stream()
                    .map(StaffCommission::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            total = total.add(lineTotal);

            PayrollItem item = PayrollItem.builder()
                    .payroll(payroll)
                    .staff(group.get(0).getStaff())
                    .recipientType(RecipientType.STAFF)
                    .commissionCount(group.size())
                    .totalAmount(lineTotal)
                    .build();
            items.add(item);
        }

        // Group delivery commissions by driver
        Map<Long, List<DeliveryCommission>> byDriver = new LinkedHashMap<>();
        for (DeliveryCommission dc : deliveryCommissions) {
            if (dc.getDriver() == null) continue;
            byDriver.computeIfAbsent(dc.getDriver().getId(), k -> new ArrayList<>()).add(dc);
        }
        for (Map.Entry<Long, List<DeliveryCommission>> entry : byDriver.entrySet()) {
            List<DeliveryCommission> group = entry.getValue();
            BigDecimal lineTotal = group.stream()
                    .map(DeliveryCommission::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            total = total.add(lineTotal);

            PayrollItem item = PayrollItem.builder()
                    .payroll(payroll)
                    .driver(group.get(0).getDriver())
                    .recipientType(RecipientType.DRIVER)
                    .commissionCount(group.size())
                    .totalAmount(lineTotal)
                    .build();
            items.add(item);
        }

        payroll.setTotalAmount(total);
        payroll.getItems().addAll(items);
        Payroll saved = payrollRepository.save(payroll);

        // Mark commissions as PAID and link payroll_id
        for (StaffCommission sc : staffCommissions) {
            sc.setStatus(CommissionStatus.PAID);
            sc.setPayrollId(saved.getId());
        }
        staffCommissionRepository.saveAll(staffCommissions);

        for (DeliveryCommission dc : deliveryCommissions) {
            dc.setStatus(CommissionStatus.PAID);
            dc.setPayrollId(saved.getId());
        }
        deliveryCommissionRepository.saveAll(deliveryCommissions);

        return toResponse(saved);
    }

    @Override
    @Transactional
    public PayrollResponse markPaid(UUID uuid) {
        Payroll payroll = payrollRepository.findByUuidWithItems(uuid)
                .orElseThrow(() -> new AppException("Payroll not found"));
        if (payroll.getStatus() == PayrollStatus.PAID) {
            throw new AppException("Payroll already marked as paid");
        }
        payroll.setStatus(PayrollStatus.PAID);
        payroll.setPaidAt(Instant.now());
        return toResponse(payrollRepository.save(payroll));
    }

    private PayrollResponse toResponse(Payroll p) {
        List<PayrollItemResponse> itemResponses = p.getItems().stream().map(i -> {
            Long recipientId;
            String recipientName;
            if (i.getRecipientType() == RecipientType.STAFF && i.getStaff() != null) {
                recipientId   = i.getStaff().getId();
                recipientName = i.getStaff().getUsername();
            } else if (i.getDriver() != null) {
                recipientId   = i.getDriver().getId();
                recipientName = i.getDriver().getName();
            } else {
                recipientId   = null;
                recipientName = null;
            }
            return PayrollItemResponse.builder()
                    .id(i.getId())
                    .recipientType(i.getRecipientType())
                    .recipientId(recipientId)
                    .recipientName(recipientName)
                    .commissionCount(i.getCommissionCount())
                    .totalAmount(i.getTotalAmount())
                    .build();
        }).toList();

        return PayrollResponse.builder()
                .id(p.getId())
                .uuid(p.getUuid())
                .weekStart(p.getWeekStart())
                .weekEnd(p.getWeekEnd())
                .totalAmount(p.getTotalAmount())
                .status(p.getStatus())
                .paidAt(p.getPaidAt())
                .note(p.getNote())
                .items(itemResponses)
                .createdAt(p.getCreatedAt())
                .updatedAt(p.getUpdatedAt())
                .build();
    }
}
