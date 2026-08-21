import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type DeliveryStatus = "PENDING" | "PICKING" | "DELIVERING" | "DELIVERED" | "FAILED" | "RETURNED";
export type DeliveryPartnerType = "R_EXPRESS" | "PERSONAL" | "OTHER";

export interface DeliveryResponse {
  id: number;
  uuid: string;
  order_uuid: string;
  recipient_name: string;
  recipient_phone: string;
  recipient_address: string | null;
  driver_id: number | null;
  driver_name: string | null;
  driver_phone: string | null;
  partner_type: DeliveryPartnerType;
  status: DeliveryStatus;
  delivery_cost: number;
  commission_earned: number;
  commission_received_at: string | null;
  delivered_at: string | null;
  note: string | null;
  created_at: string;
  updated_at: string;
}

export interface DeliveryListData {
  deliveries: DeliveryResponse[];
  meta: PageMeta;
}

export interface CreateDeliveryRequest {
  order_uuid: string;
  driver_uuid?: string;
  partner_type: DeliveryPartnerType;
  delivery_cost: number;
  note?: string;
}

export interface UpdateDeliveryStatusRequest {
  status: DeliveryStatus;
  note?: string;
}

export function fetchDeliveries(page = 1, size = 20): Promise<DeliveryListData> {
  return apiFetch<DeliveryListData>(`${ROUTES.deliveries.list}?page=${page - 1}&size=${size}`);
}

export function createDelivery(payload: CreateDeliveryRequest): Promise<DeliveryResponse> {
  return apiFetch<DeliveryResponse>(ROUTES.deliveries.create, { method: "POST", data: payload });
}

export function updateDeliveryStatus(uuid: string, payload: UpdateDeliveryStatusRequest): Promise<DeliveryResponse> {
  return apiFetch<DeliveryResponse>(ROUTES.deliveries.updateStatus(uuid), { method: "PATCH", data: payload });
}
