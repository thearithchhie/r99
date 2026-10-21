import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type PurchaseStatus =
  | "DRAFT"
  | "ORDERED"
  | "PARTIALLY_RECEIVED"
  | "RECEIVED"
  | "CANCELLED";

export interface PurchaseItemResponse {
  uuid: string;
  product_uuid: string;
  product_name: string;
  product_code: string;
  quantity: number;
  received_quantity: number;
  remaining_quantity: number;
  cost_price: number;
  discount_amount: number;
  subtotal: number;
}

export interface PurchaseResponse {
  id: number;
  uuid: string;
  order_number: string;
  status: PurchaseStatus;
  supplier_uuid: string;
  supplier_name: string;
  subtotal: number;
  discount_amount: number;
  tax_amount: number;
  shipping_cost: number;
  total_amount: number;
  items: PurchaseItemResponse[];
  note: string | null;
  ordered_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface PurchaseListData {
  purchases: PurchaseResponse[];
  meta: PageMeta;
}

export interface PurchaseItemRequest {
  product_uuid: string;
  quantity: number;
  cost_price: number;
  discount_amount?: number;
}

export interface CreatePurchaseRequest {
  supplier_uuid: string;
  items: PurchaseItemRequest[];
  discount_amount?: number;
  tax_amount?: number;
  shipping_cost?: number;
  note?: string;
}

export interface ReceiveItemRequest {
  purchase_item_uuid: string;
  received_quantity: number;
}

export interface ReceivePurchaseRequest {
  items: ReceiveItemRequest[];
  note?: string;
}

export function fetchPurchases(params: {
  page?: number;
  size?: number;
  status?: PurchaseStatus | "";
  supplier_uuid?: string;
} = {}): Promise<PurchaseListData> {
  const { page = 1, size = 20, status, supplier_uuid } = params;
  const qs = new URLSearchParams();
  qs.set("page", String(page - 1));
  qs.set("size", String(size));
  if (status) qs.set("status", status);
  if (supplier_uuid) qs.set("supplier_uuid", supplier_uuid);
  return apiFetch<PurchaseListData>(`${ROUTES.purchases.list}?${qs}`);
}

export function fetchPurchase(uuid: string): Promise<PurchaseResponse> {
  return apiFetch<PurchaseResponse>(ROUTES.purchases.detail(uuid));
}

export function createPurchase(payload: CreatePurchaseRequest): Promise<PurchaseResponse> {
  return apiFetch<PurchaseResponse>(ROUTES.purchases.create, {
    method: "POST",
    data: payload,
  });
}

export function confirmPurchase(uuid: string): Promise<PurchaseResponse> {
  return apiFetch<PurchaseResponse>(ROUTES.purchases.confirm(uuid), {
    method: "POST",
  });
}

export function receivePurchase(
  uuid: string,
  payload: ReceivePurchaseRequest,
): Promise<PurchaseResponse> {
  return apiFetch<PurchaseResponse>(ROUTES.purchases.receive(uuid), {
    method: "POST",
    data: payload,
  });
}

export function cancelPurchase(uuid: string): Promise<PurchaseResponse> {
  return apiFetch<PurchaseResponse>(ROUTES.purchases.cancel(uuid), {
    method: "POST",
  });
}

export interface ArrivalRecord {
  product_uuid: string;
  product_name: string;
  product_code: string;
  quantity_received: number;
  arrived_at: string;
}

export function fetchPurchaseArrivals(uuid: string): Promise<ArrivalRecord[]> {
  return apiFetch<ArrivalRecord[]>(ROUTES.purchases.arrivals(uuid));
}
