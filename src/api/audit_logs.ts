import { apiFetch } from "./http";
import type { PageMeta } from "./users";

export interface AuditLogResponse {
  id: number;
  user_id: number;
  user_name: string | null;
  context: string;
  description: string;
  user_agent: string;
  operator: string;
  ip: string;
  status_id: number;
  priority: number;
  created_by: number | null;
  created_at: string;
}

export interface AuditLogListData {
  audit_logs: AuditLogResponse[];
  meta: PageMeta;
}

export function fetchAuditLogs(page = 1, size = 15): Promise<AuditLogListData> {
  return apiFetch<AuditLogListData>(`/api/v1/audit-logs?page=${page - 1}&size=${size}`);
}
