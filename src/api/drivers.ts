import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export interface DriverResponse {
  id: number;
  uuid: string;
  name: string;
  phone: string;
  note: string | null;
  created_at: string;
  updated_at: string;
}

export interface DriverListData {
  drivers: DriverResponse[];
  meta: PageMeta;
}

export interface DriverRequest {
  name: string;
  phone: string;
  note?: string;
}

export function fetchDrivers(size = 20): Promise<DriverListData> {
  return apiFetch<DriverListData>(`${ROUTES.drivers.list}?size=${size}`);
}

export function createDriver(payload: DriverRequest): Promise<DriverResponse> {
  return apiFetch<DriverResponse>(ROUTES.drivers.create, { method: "POST", data: payload });
}

export function deleteDriver(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.drivers.delete(uuid), { method: "DELETE" });
}
