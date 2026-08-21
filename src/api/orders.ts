import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type OrderStatus = "PENDING" | "CONFIRMED" | "DELIVERING" | "DELIVERED" | "CANCELLED" | "RETURNED" | "PARTIALLY_RETURNED";
export type ReturnReason = "CUSTOMER_CHANGE" | "SIZE_CHANGE" | "STORE_ERROR" | "CUSTOMER_RETURN";
export type PageSource = "R99" | "R99_I";
export type PaymentType = "PAID_UPFRONT" | "PAY_ON_DELIVERY";
export type PaymentMethod = "BANK" | "CASH";

export interface OrderItem {
  product_id: number;
  product_uuid: string;
  product_code: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  unit_cost: number;
  subtotal: number;
}

export interface PartialReturnRequest {
  return_reason: ReturnReason;
  note?: string;
  items: { product_uuid: string; quantity: number }[];
}

export interface OrderResponse {
  id: number;
  uuid: string;
  status: OrderStatus;
  return_reason: ReturnReason | null;
  customer_id: number;
  customer_name: string;
  customer_phone: string;
  staff_id: number;
  staff_name: string;
  page_source: PageSource;
  payment_type: PaymentType;
  payment_method: PaymentMethod | null;
  is_promotion: boolean;
  subtotal: number;
  delivery_fee: number;
  total_amount: number;
  note: string | null;
  items: OrderItem[];
  created_at: string;
  updated_at: string;
}

export interface OrderListData {
  orders: OrderResponse[];
  meta: PageMeta;
}

export interface CreateOrderRequest {
  customer_uuid: string;
  staff_uuid?: string;
  page_source: PageSource;
  payment_type: PaymentType;
  payment_method?: PaymentMethod;
  is_promotion: boolean;
  note?: string;
  items: { product_uuid: string; quantity: number }[];
}

export interface UpdateOrderStatusRequest {
  status: OrderStatus;
  return_reason?: ReturnReason;
  note?: string;
}

export function fetchOrders(page = 1, size = 20, status?: OrderStatus): Promise<OrderListData> {
  const params = new URLSearchParams({ page: String(page - 1), size: String(size) });
  if (status) params.set("status", status);
  return apiFetch<OrderListData>(`${ROUTES.orders.list}?${params}`);
}

export function fetchOrder(uuid: string): Promise<OrderResponse> {
  return apiFetch<OrderResponse>(ROUTES.orders.detail(uuid));
}

export function createOrder(payload: CreateOrderRequest): Promise<OrderResponse> {
  return apiFetch<OrderResponse>(ROUTES.orders.create, { method: "POST", data: payload });
}

export function updateOrderStatus(uuid: string, payload: UpdateOrderStatusRequest): Promise<OrderResponse> {
  return apiFetch<OrderResponse>(ROUTES.orders.updateStatus(uuid), { method: "PATCH", data: payload });
}

export function partialReturnOrder(uuid: string, payload: PartialReturnRequest): Promise<OrderResponse> {
  return apiFetch<OrderResponse>(ROUTES.orders.partialReturn(uuid), { method: "PATCH", data: payload });
}
