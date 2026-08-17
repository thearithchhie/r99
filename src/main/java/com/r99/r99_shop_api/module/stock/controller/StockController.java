package com.r99.r99_shop_api.module.stock.controller;

import com.r99.r99_shop_api.common.response.ApiResponse;
import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.common.util.PageableUtil;
import com.r99.r99_shop_api.module.stock.dto.request.StockMovementRequest;
import com.r99.r99_shop_api.module.stock.dto.response.StockLevelResponse;
import com.r99.r99_shop_api.module.stock.dto.response.StockMovementResponse;
import com.r99.r99_shop_api.module.stock.service.StockService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/stock")
@RequiredArgsConstructor
public class StockController {

    private final StockService stockService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<StockLevelResponse>>> listLevels(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                stockService.findAll(PageableUtil.withDefaultSort(pageable))));
    }

    @GetMapping("/movements")
    public ResponseEntity<ApiResponse<PagedResponse<StockMovementResponse>>> listMovements(
            @PageableDefault(size = PageableUtil.DEFAULT_PAGE_SIZE) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                stockService.findMovements(PageableUtil.withDefaultSort(pageable))));
    }

    @PostMapping("/movements")
    public ResponseEntity<ApiResponse<StockMovementResponse>> addMovement(
            @Valid @RequestBody StockMovementRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(stockService.addMovement(request)));
    }
}
