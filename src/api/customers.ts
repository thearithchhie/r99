import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export interface CustomerResponse {
  id: number;
  uuid: string;
  name: string;
  phone: string;
  address: string | null;
  province: string | null;
  facebook_name: string | null;
  note: string | null;
  created_at: string;
  updated_at: string;
}

export interface CustomerListData {
  customers: CustomerResponse[];
  meta: PageMeta;
}

export interface CustomerRequest {
  name: string;
  phone: string;
  address?: string;
  province?: string;
  facebook_name?: string;
}

export function fetchCustomers(page = 1, size = 20): Promise<CustomerListData> {
  return apiFetch<CustomerListData>(`${ROUTES.customers.list}?page=${page - 1}&size=${size}`);
}

export function searchCustomers(q: string): Promise<CustomerResponse[]> {
  return apiFetch<CustomerResponse[]>(`${ROUTES.customers.search}?q=${encodeURIComponent(q)}`);
}

export function createCustomer(payload: CustomerRequest): Promise<CustomerResponse> {
  return apiFetch<CustomerResponse>(ROUTES.customers.create, { method: "POST", data: payload });
}

export function updateCustomer(uuid: string, payload: Partial<CustomerRequest>): Promise<CustomerResponse> {
  return apiFetch<CustomerResponse>(ROUTES.customers.update(uuid), { method: "PATCH", data: payload });
}

export function deleteCustomer(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.customers.delete(uuid), { method: "DELETE" });
}
