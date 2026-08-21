import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export interface StockLevelResponse {
  id: number;
  product_id: number;
  product_code: string;
  product_name: string;
  quantity: number;
  updated_at: string;
}

export interface StockListData {
  stock_levels: StockLevelResponse[];
  meta: PageMeta;
}

export function fetchStockLevels(page = 1, size = 10): Promise<StockListData> {
  return apiFetch<StockListData>(`${ROUTES.stocks.list}?page=${page - 1}&size=${size}`);
}

export interface StockMovementResponse {
  id: number;
  product_id: number;
  product_code: string;
  product_name: string;
  delta: number;
  reason: string;
  reference_id: number | null;
  note: string | null;
  created_by: number;
  created_at: string;
}

export interface StockMovementListData {
  stock_movements: StockMovementResponse[];
  meta: PageMeta;
}

export function fetchStockMovements(page = 1, size = 10): Promise<StockMovementListData> {
  return apiFetch<StockMovementListData>(`${ROUTES.stocks.movements}?page=${page - 1}&size=${size}`);
}

export interface CreateStockMovementRequest {
  product_uuid: string;
  delta: number;
  reason: string;
  reference_id?: string;
  note?: string;
}

export function createStockMovement(payload: CreateStockMovementRequest): Promise<StockMovementResponse> {
  return apiFetch<StockMovementResponse>(ROUTES.stocks.movements, {
    method: "POST",
    data: payload,
  });
}
