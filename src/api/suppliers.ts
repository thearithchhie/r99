import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type SupplierStatus = "ACTIVE" | "INACTIVE";

export interface SupplierResponse {
  id: number;
  uuid: string;
  name: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  contact_person: string | null;
  status: SupplierStatus;
  created_at: string;
  updated_at: string;
}

export interface SupplierListData {
  suppliers: SupplierResponse[];
  meta: PageMeta;
}

export interface SupplierRequest {
  name: string;
  phone?: string;
  email?: string;
  address?: string;
  contact_person?: string;
}

export interface SupplierUpdateRequest extends Partial<SupplierRequest> {
  status?: SupplierStatus;
}

export function fetchSuppliers(params: {
  page?: number;
  size?: number;
  search?: string;
  status?: SupplierStatus | "";
} = {}): Promise<SupplierListData> {
  const { page = 1, size = 20, search, status } = params;
  const qs = new URLSearchParams();
  qs.set("page", String(page - 1));
  qs.set("size", String(size));
  if (search) qs.set("search", search);
  if (status) qs.set("status", status);
  return apiFetch<SupplierListData>(`${ROUTES.suppliers.list}?${qs}`);
}

export function fetchSupplier(uuid: string): Promise<SupplierResponse> {
  return apiFetch<SupplierResponse>(ROUTES.suppliers.detail(uuid));
}

export function createSupplier(payload: SupplierRequest): Promise<SupplierResponse> {
  return apiFetch<SupplierResponse>(ROUTES.suppliers.create, {
    method: "POST",
    data: payload,
  });
}

export function updateSupplier(uuid: string, payload: SupplierUpdateRequest): Promise<SupplierResponse> {
  return apiFetch<SupplierResponse>(ROUTES.suppliers.update(uuid), {
    method: "PUT",
    data: payload,
  });
}

export function deleteSupplier(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.suppliers.delete(uuid), { method: "DELETE" });
}
