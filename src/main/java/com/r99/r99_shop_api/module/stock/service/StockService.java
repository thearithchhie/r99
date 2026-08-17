package com.r99.r99_shop_api.module.stock.service;

import com.r99.r99_shop_api.common.response.PagedResponse;
import com.r99.r99_shop_api.module.stock.dto.request.StockMovementRequest;
import com.r99.r99_shop_api.module.stock.dto.response.StockLevelResponse;
import com.r99.r99_shop_api.module.stock.dto.response.StockMovementResponse;
import org.springframework.data.domain.Pageable;

public interface StockService {

    PagedResponse<StockLevelResponse> findAll(Pageable pageable);

    PagedResponse<StockMovementResponse> findMovements(Pageable pageable);

    StockMovementResponse addMovement(StockMovementRequest request);
}
