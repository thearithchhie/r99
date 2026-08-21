package com.r99.r99_shop_api.module.payroll.repository;

import com.r99.r99_shop_api.module.payroll.entity.PayrollItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PayrollItemRepository extends JpaRepository<PayrollItem, Long> {

    List<PayrollItem> findByPayrollId(Long payrollId);
}
