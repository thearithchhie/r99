import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type PayrollStatus = "DRAFT" | "PAID";
export type RecipientType = "STAFF" | "DRIVER";

export interface PayrollItem {
  id: number;
  recipient_type: RecipientType;
  recipient_id: number;
  recipient_name: string;
  commission_count: number;
  total_amount: number;
}

export interface PayrollResponse {
  id: number;
  uuid: string;
  week_start: string;
  week_end: string;
  total_amount: number;
  status: PayrollStatus;
  paid_at: string | null;
  note: string | null;
  items: PayrollItem[];
  created_at: string;
  updated_at: string;
}

export interface PayrollListData {
  payrolls: PayrollResponse[];
  meta: PageMeta;
}

export interface GeneratePayrollRequest {
  week_start: string;
  week_end: string;
  note?: string;
  staff_uuids?: string[];
  driver_uuids?: string[];
}

export function fetchPayrolls(page = 1, size = 20): Promise<PayrollListData> {
  return apiFetch<PayrollListData>(`${ROUTES.payrolls.list}?page=${page - 1}&size=${size}`);
}

export function fetchPayroll(uuid: string): Promise<PayrollResponse> {
  return apiFetch<PayrollResponse>(ROUTES.payrolls.detail(uuid));
}

export function generatePayroll(payload: GeneratePayrollRequest): Promise<PayrollResponse> {
  return apiFetch<PayrollResponse>(ROUTES.payrolls.generate, { method: "POST", data: payload });
}

export function markPayrollPaid(uuid: string): Promise<PayrollResponse> {
  return apiFetch<PayrollResponse>(ROUTES.payrolls.markPaid(uuid), { method: "PATCH" });
}
